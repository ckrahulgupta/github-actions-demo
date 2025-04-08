/**
 * @company           : Cloudkaptan Consultancy Services Pvt. Ltd.
 * @description       : This is a Helper class which generates the request-body for the NLS Adpter Class. 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-03-2025
 * @last modified by  : Kabir Pramanik
**/

public with sharing class RequestBodyGeneratorHelper {
    private static final String LOAN = 'LOAN'; 
    private static final String LOAN_NUMBER = 'LoanNumber';
    private static final String UPDATE_FLAG = 'UpdateFlag';
    private static final String LOAN_CREDIT_LINE = 'LOANCREDITLINE';
    private static final String NAME = 'Name';
    private static final String CREDIT_TOTAL_DRAW_LIMIT = 'CreditTotalDrawLimit';
    private static final String CREDIT_LINE_LIMIT = 'CreditLineLimit';
    private static final String CURR_MATURITY_DATE='MaturityDate';
    private static final String XML_DOCTYPE = '<?xml version="1.0" encoding="UTF-8"?>';    
    private static final String NLS = 'NLS';
    private static final String KEY_COOP_TYPE = 'coopType';
    private static final String KEY_PARTNER_PROGRAM = 'PartnerProgram';
    private static final String STATEMENT_ONE_CODE = 'Statement1Code';
    private static final Decimal NEW_RATE_CARD_YEAR = 2024;
    private static final String KEY_LOAN_NUM = 'loanNumber';
    private static final String KEY_PRICING_COUNT = 'pricingCount';
    List<Map<String, Object>> partnerProgram;    
    private static final String KEY_APPLICATION = 'Application';
    private static final String KEY_ADDRESS = 'DealerAddress';
    private static final String KEY_PRICING_DETAILS_A = 'PricingDetailA';
    private static final String KEY_PRICING_DETAILS_B = 'PricingDetailB';
    private static final String KEY_PRICING_DETAILS_C = 'PricingDetailC';
    private static final String KEY_PRICING_DETAILS_D = 'PricingDetailD';
    private static final String KEY_PRICING_DETAILS_E = 'PricingDetailE';
    private static final String KEY_PRICING_DETAILS_F = 'PricingDetailF';
    private static final String KEY_PRICING_DETAILS_G = 'PricingDetailG';
    private static final String KEY_PRICING_DETAILS_H = 'PricingDetailH';
    private static final String KEY_MY_PROGRAM = 'MyProgramHeader';
    private static final String KEY_APPLICATION_RESPONSE = 'applicationResponse';
    private static final String KEY_DEALER_ADDRESS = 'dealerAddress';
    private static final String KEY_MY_PROGRAM_HEADER = 'myProgramHeader';
    private static final String KEY_PRICING_DETAILS = 'pricingDetails';

    String requestBody;
    Map<String, String> entityMap = new Map<String, String> {
        'Corporation' => 'CORPORATION' ,
        'Individual' => 'INDIVIDUAL',
        'Individual(s) - Sole Proprietorship' => 'INDIVIDUAL',
        'Individual(s) with DBA' => 'INDIVIDUAL(S) W/ DBA',
        'Joint Venture' => 'JOINT VENTURE',
        'Limited Liability Company' => 'LIMITED LIABILITY COMPANY',
        'Partnership' => 'PARTNERSHIP',
        'Limited Partnership' => 'PARTNERSHIP',
        'General Partnership' => 'PARTNERSHIP',
        'Trust' => 'TRUST'
    };

    List<Map<String, Object>> applicationResponses = new List<Map<String, Object>>();
    List<Map<String, Object>> dealerAddress = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanA = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanB = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanC = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanD = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanE = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanF = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanG = new List<Map<String, Object>>();
    List<Map<String, Object>> childLoanH = new List<Map<String, Object>>();
    List<Map<String, Object>> myProgramHeader = new List<Map<String, Object>>();


    /**
     * @description Generate request body to get the child loan details from NLS using Parent loan Id
     * @param loanId 
     * @return  `String`
     */
    public String generateRequestForChildLoanId(String loanId){

        requestBody = '{"Portfolio_Code_Id": "","Acctrefno": "","Loan_Number": "","Cifno": "","Cifnumber": "",'
        +'"Loan_Group_No": "","Investor": {"Cifnumber": ""},"Shortname": "","Name": "",'
        +'"Loan_Class1_No": "","Loan_Class2_No": "","Risk_Rating_No": "","Entity": "","Tin": "",'
        +'"Tin_Hash": "","Status_Code_No": "","Status_Codes": {"HasNone": false,'
        +'"ApplyOrOperator": false,"SelectionsToInclude": [],"SelectionsToExclude": []},"Loan_Officer_No": "",'
        +'"Collection_Officer_No": "","Input_Date": "","Open_Date": "","Curr_Date": "",'
        +'"Curr_Maturity_Date": "","Payoff_Date": "","Closed_Date": "","Last_Activity_Date": "",'
        +'"Interest_Accrued_Thru_Date": "","Interest_Paid_Thru_Date": "","Principal_Paid_Thru_Date": "",'
        +'"Next_Statement1_Date": "","Next_Accrual_Cutoff": "","Loan_Type": "","Interest_Method": "",'
        +'"Current_Interest_Rate": "","Term": "","Term_Due": "","Term_Char": "","SAC_Expiration_Date": "",'
        +'"SAC_Ineligible_Date": "","Credit_Line_Limit": "","Current_Note_Amount": "",'
        +'"Current_Perdiem": "","Current_Servicing_Balance": "","Current_Principal_Balance": "",'
        +'"Current_Interest_Balance": "","Current_Def_Interest_Balance": "","Current_Fees_Balance": "",'
        +'"Current_Late_Charge_Balance": "","Current_Udf1_Balance": "","Current_Udf2_Balance": "",'
        +'"Current_Udf3_Balance": "","Current_Udf4_Balance": "","Current_Udf5_Balance": "",'
        +'"Current_Udf6_Balance": "","Current_Udf7_Balance": "","Current_Udf8_Balance": "",'
        +'"Current_Udf9_Balance": "","Current_Udf10_Balance": "","Current_Payoff_Balance": "",'
        +'"Current_Suspense": "","Current_Impound_Balance": "","Current_Ol1_Balance": "",'
        +'"Current_Ol2_Balance": "","Current_Ol3_Balance": "","Balloon_Payment_Amount": "",'
        +'"Balloon_Payment_Date": "","Next_Principal_Due_Amount": "","Next_Principal_Payment_Date": "",'
        +'"Next_Interest_Due_Amount": "","Next_Interest_Payment_Date": "","Next_Payment_Total_Amount": "",'
        +'"Last_Payment_Amount": "","Last_Payment_Date": "","Total_Past_Due_Balance": "",'
        +'"Days_Past_Due": "","Total_Current_Due_Balance": "","InterestOnlyPeriod": false,'
        +'"ParentOfShadowLoan": false,"Participant": {"Participantrefno": "","Participant_Number": "",'
        +'"Shortname": "","Loan_Group_No": ""},"Cif_Loan_Relationship": {"Cifno": "","Cifnumber": "","Relationship_Code_Id": ""},"Transaction_History": {"Transaction_Date": "",'
        +'"Effective_Date": "","Gl_Date": "","Transaction_Code": "","Transaction_Amount": "",'
        +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
        +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": ""},'
        +'"Payment_History": {"Date_Due": "","Date_Paid": "","Gl_Date": "","Payment_Amount": "",'
        +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
        +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": "","SearchPayoffsOnly": false,'
        +'"SearchPaymentsOnly": false},"Promise_To_Pay": {"Promise_Date": "","Promise_Kept_Date": "",'
        +'"Promise_Amount": "","SearchBrokenPromisesOnly": false,"SearchSoftBrokenPromisesOnly": false,'
        +'"Promise_Broken_Date": "","Promise_Softbroken_Date": ""},"Next_Impound_Analysis_Date": "",'
        +'"Branch_Cifno": "","BranchDivisionID": "","Dealer_Cifno": "","Master_Acctrefno": "'+loanId+'",'
        +'"Pool_Acctrefno": ""}';

        return requestBody;
    }    

    /**
     * @description This method generate the request body to get the Loan details using Loan Number
     * @param loanNumber 
     * @return  `String`
     */
    public String generateRequestForLoanId(String loanNumber){

        requestBody = '{"Portfolio_Code_Id": "","Acctrefno": "","Loan_Number": "'+loanNumber+'","Cifno": "","Cifnumber": "",'
        +'"Loan_Group_No": "","Investor": {"Cifnumber": ""},"Shortname": "","Name": "",'
        +'"Loan_Class1_No": "","Loan_Class2_No": "","Risk_Rating_No": "","Entity": "","Tin": "",'
        +'"Tin_Hash": "","Status_Code_No": "","Status_Codes": {"HasNone": false,'
        +'"ApplyOrOperator": false,"SelectionsToInclude": [],"SelectionsToExclude": []},"Loan_Officer_No": "",'
        +'"Collection_Officer_No": "","Input_Date": "","Open_Date": "","Curr_Date": "",'
        +'"Curr_Maturity_Date": "","Payoff_Date": "","Closed_Date": "","Last_Activity_Date": "",'
        +'"Interest_Accrued_Thru_Date": "","Interest_Paid_Thru_Date": "","Principal_Paid_Thru_Date": "",'
        +'"Next_Statement1_Date": "","Next_Accrual_Cutoff": "","Loan_Type": "","Interest_Method": "",'
        +'"Current_Interest_Rate": "","Term": "","Term_Due": "","Term_Char": "","SAC_Expiration_Date": "",'
        +'"SAC_Ineligible_Date": "","Credit_Line_Limit": "","Current_Note_Amount": "",'
        +'"Current_Perdiem": "","Current_Servicing_Balance": "","Current_Principal_Balance": "",'
        +'"Current_Interest_Balance": "","Current_Def_Interest_Balance": "","Current_Fees_Balance": "",'
        +'"Current_Late_Charge_Balance": "","Current_Udf1_Balance": "","Current_Udf2_Balance": "",'
        +'"Current_Udf3_Balance": "","Current_Udf4_Balance": "","Current_Udf5_Balance": "",'
        +'"Current_Udf6_Balance": "","Current_Udf7_Balance": "","Current_Udf8_Balance": "",'
        +'"Current_Udf9_Balance": "","Current_Udf10_Balance": "","Current_Payoff_Balance": "",'
        +'"Current_Suspense": "","Current_Impound_Balance": "","Current_Ol1_Balance": "",'
        +'"Current_Ol2_Balance": "","Current_Ol3_Balance": "","Balloon_Payment_Amount": "",'
        +'"Balloon_Payment_Date": "","Next_Principal_Due_Amount": "","Next_Principal_Payment_Date": "",'
        +'"Next_Interest_Due_Amount": "","Next_Interest_Payment_Date": "","Next_Payment_Total_Amount": "",'
        +'"Last_Payment_Amount": "","Last_Payment_Date": "","Total_Past_Due_Balance": "",'
        +'"Days_Past_Due": "","Total_Current_Due_Balance": "","InterestOnlyPeriod": false,'
        +'"ParentOfShadowLoan": false,"Participant": {"Participantrefno": "","Participant_Number": "",'
        +'"Shortname": "","Loan_Group_No": ""},"Cif_Loan_Relationship": {"Cifno": "","Cifnumber": "","Relationship_Code_Id": ""},"Transaction_History": {"Transaction_Date": "",'
        +'"Effective_Date": "","Gl_Date": "","Transaction_Code": "","Transaction_Amount": "",'
        +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
        +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": ""},'
        +'"Payment_History": {"Date_Due": "","Date_Paid": "","Gl_Date": "","Payment_Amount": "",'
        +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
        +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": "","SearchPayoffsOnly": false,'
        +'"SearchPaymentsOnly": false},"Promise_To_Pay": {"Promise_Date": "","Promise_Kept_Date": "",'
        +'"Promise_Amount": "","SearchBrokenPromisesOnly": false,"SearchSoftBrokenPromisesOnly": false,'
        +'"Promise_Broken_Date": "","Promise_Softbroken_Date": ""},"Next_Impound_Analysis_Date": "",'
        +'"Branch_Cifno": "","BranchDivisionID": "","Dealer_Cifno": "","Master_Acctrefno": "",'
        +'"Pool_Acctrefno": ""}';

        return requestBody;
    }    

    /**
     * @description This method generate the request body to get the Loan Details using CIF Number.
     * @param partyType 
     * @param cifNumber 
     * @param loanStatus 
     * @param loanType 
     * @param masterAcctrefno 
     * @param payoffDate 
     * @return  `String`
     */
    public String generateRequestbody(String partyType, String cifNumber, String loanStatus, String loanType, String masterAcctrefno, String payoffDate){ 
        
        String requestBody;
        // if party type not grower 
        if(!partyType.equalsIgnoreCase('GROWER')){


            requestBody = '{"Portfolio_Code_Id": "","Acctrefno": "","Loan_Number": "","Cifno": "","Cifnumber": "",'
                    +'"Loan_Group_No": "","Investor": {"Cifnumber": ""},"Shortname": "","Name": "",'
                    +'"Loan_Class1_No": "","Loan_Class2_No": "","Risk_Rating_No": "","Entity": "","Tin": "",'
                    +'"Tin_Hash": "","Status_Code_No": "'+ loanStatus +'","Status_Codes": {"HasNone": false,'
                    +'"ApplyOrOperator": false,"SelectionsToInclude": [],"SelectionsToExclude": []},"Loan_Officer_No": "",'
                    +'"Collection_Officer_No": "","Input_Date": "","Open_Date": "","Curr_Date": "",'
                    +'"Curr_Maturity_Date": "","Payoff_Date": '+payoffDate+',"Closed_Date": "","Last_Activity_Date": "",'
                    +'"Interest_Accrued_Thru_Date": "","Interest_Paid_Thru_Date": "","Principal_Paid_Thru_Date": "",'
                    +'"Next_Statement1_Date": "","Next_Accrual_Cutoff": "","Loan_Type": "'+ loanType +'","Interest_Method": "",'
                    +'"Current_Interest_Rate": "","Term": "","Term_Due": "","Term_Char": "","SAC_Expiration_Date": "",'
                    +'"SAC_Ineligible_Date": "","Credit_Line_Limit": "","Current_Note_Amount": "",'
                    +'"Current_Perdiem": "","Current_Servicing_Balance": "","Current_Principal_Balance": "",'
                    +'"Current_Interest_Balance": "","Current_Def_Interest_Balance": "","Current_Fees_Balance": "",'
                    +'"Current_Late_Charge_Balance": "","Current_Udf1_Balance": "","Current_Udf2_Balance": "",'
                    +'"Current_Udf3_Balance": "","Current_Udf4_Balance": "","Current_Udf5_Balance": "",'
                    +'"Current_Udf6_Balance": "","Current_Udf7_Balance": "","Current_Udf8_Balance": "",'
                    +'"Current_Udf9_Balance": "","Current_Udf10_Balance": "","Current_Payoff_Balance": "",'
                    +'"Current_Suspense": "","Current_Impound_Balance": "","Current_Ol1_Balance": "",'
                    +'"Current_Ol2_Balance": "","Current_Ol3_Balance": "","Balloon_Payment_Amount": "",'
                    +'"Balloon_Payment_Date": "","Next_Principal_Due_Amount": "","Next_Principal_Payment_Date": "",'
                    +'"Next_Interest_Due_Amount": "","Next_Interest_Payment_Date": "","Next_Payment_Total_Amount": "",'
                    +'"Last_Payment_Amount": "","Last_Payment_Date": "","Total_Past_Due_Balance": "",'
                    +'"Days_Past_Due": "","Total_Current_Due_Balance": "","InterestOnlyPeriod": false,'
                    +'"ParentOfShadowLoan": false,"Participant": {"Participantrefno": "","Participant_Number": "",'
                    +'"Shortname": "","Loan_Group_No": ""},"Cif_Loan_Relationship": {"Cifno": "","Cifnumber": "'
                    + cifNumber +'","Relationship_Code_Id": ""},"Transaction_History": {"Transaction_Date": "",'
                    +'"Effective_Date": "","Gl_Date": "","Transaction_Code": "","Transaction_Amount": "",'
                    +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
                    +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": ""},'
                    +'"Payment_History": {"Date_Due": "","Date_Paid": "","Gl_Date": "","Payment_Amount": "",'
                    +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
                    +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": "","SearchPayoffsOnly": false,'
                    +'"SearchPaymentsOnly": false},"Promise_To_Pay": {"Promise_Date": "","Promise_Kept_Date": "",'
                    +'"Promise_Amount": "","SearchBrokenPromisesOnly": false,"SearchSoftBrokenPromisesOnly": false,'
                    +'"Promise_Broken_Date": "","Promise_Softbroken_Date": ""},"Next_Impound_Analysis_Date": "",'
                    +'"Branch_Cifno": "","BranchDivisionID": "","Dealer_Cifno": "","Master_Acctrefno": "'+ masterAcctrefno +'",'
                    +'"Pool_Acctrefno": ""}';
        } else if(partyType.equalsIgnoreCase('GROWER')){
            requestBody = '{"Portfolio_Code_Id": "","Acctrefno": "","Loan_Number": "","Cifno": "","Cifnumber": "'
                    + cifNumber +'","Loan_Group_No": "","Investor": {"Cifnumber": ""},"Shortname": "","Name": "",'
                    +'"Loan_Class1_No": "","Loan_Class2_No": "","Risk_Rating_No": "","Entity": "","Tin": "",'
                    +'"Tin_Hash": "","Status_Code_No": "'+ loanStatus +'","Status_Codes": {"HasNone": false,'
                    +'"ApplyOrOperator": false,"SelectionsToInclude": [],"SelectionsToExclude": []},"Loan_Officer_No": "",'
                    +'"Collection_Officer_No": "","Input_Date": "","Open_Date": "","Curr_Date": "",'
                    +'"Curr_Maturity_Date": "","Payoff_Date": "","Closed_Date": "","Last_Activity_Date": "",'
                    +'"Interest_Accrued_Thru_Date": "","Interest_Paid_Thru_Date": "","Principal_Paid_Thru_Date": "",'
                    +'"Next_Statement1_Date": "","Next_Accrual_Cutoff": "","Loan_Type": "'+ loanType +'","Interest_Method": "",'
                    +'"Current_Interest_Rate": "","Term": "","Term_Due": "","Term_Char": "","SAC_Expiration_Date": "",'
                    +'"SAC_Ineligible_Date": "","Credit_Line_Limit": "","Current_Note_Amount": "",'
                    +'"Current_Perdiem": "","Current_Servicing_Balance": "","Current_Principal_Balance": "",'
                    +'"Current_Interest_Balance": "","Current_Def_Interest_Balance": "","Current_Fees_Balance": "",'
                    +'"Current_Late_Charge_Balance": "","Current_Udf1_Balance": "","Current_Udf2_Balance": "",'
                    +'"Current_Udf3_Balance": "","Current_Udf4_Balance": "","Current_Udf5_Balance": "",'
                    +'"Current_Udf6_Balance": "","Current_Udf7_Balance": "","Current_Udf8_Balance": "",'
                    +'"Current_Udf9_Balance": "","Current_Udf10_Balance": "","Current_Payoff_Balance": "",'
                    +'"Current_Suspense": "","Current_Impound_Balance": "","Current_Ol1_Balance": "",'
                    +'"Current_Ol2_Balance": "","Current_Ol3_Balance": "","Balloon_Payment_Amount": "",'
                    +'"Balloon_Payment_Date": "","Next_Principal_Due_Amount": "","Next_Principal_Payment_Date": "",'
                    +'"Next_Interest_Due_Amount": "","Next_Interest_Payment_Date": "","Next_Payment_Total_Amount": "",'
                    +'"Last_Payment_Amount": "","Last_Payment_Date": "","Total_Past_Due_Balance": "",'
                    +'"Days_Past_Due": "","Total_Current_Due_Balance": "","InterestOnlyPeriod": false,'
                    +'"ParentOfShadowLoan": false,"Participant": {"Participantrefno": "","Participant_Number": "",'
                    +'"Shortname": "","Loan_Group_No": ""},"Cif_Loan_Relationship": {"Cifno": "","Cifnumber": "'
                    +'","Relationship_Code_Id": ""},"Transaction_History": {"Transaction_Date": "",'
                    +'"Effective_Date": "","Gl_Date": "","Transaction_Code": "","Transaction_Amount": "",'
                    +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
                    +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": ""},'
                    +'"Payment_History": {"Date_Due": "","Date_Paid": "","Gl_Date": "","Payment_Amount": "",'
                    +'"User_Reference": "","Payment_Method_No": "","Payment_Method_Reference": "","Userdef01": "",'
                    +'"Userdef02": "","Userdef03": "","Userdef04": "","Userdef05": "","SearchPayoffsOnly": false,'
                    +'"SearchPaymentsOnly": false},"Promise_To_Pay": {"Promise_Date": "","Promise_Kept_Date": "",'
                    +'"Promise_Amount": "","SearchBrokenPromisesOnly": false,"SearchSoftBrokenPromisesOnly": false,'
                    +'"Promise_Broken_Date": "","Promise_Softbroken_Date": ""},"Next_Impound_Analysis_Date": "",'
                    +'"Branch_Cifno": "","BranchDivisionID": "","Dealer_Cifno": "","Master_Acctrefno": "'+ masterAcctrefno +'",'
                    +'"Pool_Acctrefno": ""}';
        }
        return requestBody; // retuning the request body to the NLSLoanSearchAdapter class 
    }
    
    /**
     * @description This method generate the request body to post all type of transaction in NLS 
     * @param type 
     * @param responses 
     * @return  `String`
     */
    public String generateXMLRequestbody(String type, List<Map<String, Object>> responses){
        
        String effectiveDate =  Date.today().format();
        DOM.Document doc = new DOM.Document();
        dom.XmlNode nls = doc.createRootElement('NLS',null,null);
        dom.XmlNode header = nls.addChildElement('TRANSACTIONS',null,null);
        header.setAttribute('CommitEachTransaction','1');
        header.setAttribute('BatchReference','0');
        Boolean showOptions = true;
        Map<String, List<Map<String, Object>>> loanMap = new Map<String, List<Map<String, Object>>>();
        List<String> applicationIdList = new List<String>();
        for(Map<String, Object> response: responses){
            if(loanMap.get(String.valueOf(response.get('ParentLoanNumber'))) != null){
                List<Map<String, Object>> loanList = loanMap.get(String.valueOf(response.get('ParentLoanNumber')));
                loanList.add(response);
                loanMap.remove(String.valueOf(response.get('ParentLoanNumber')));
                loanMap.put(String.valueOf(response.get('ParentLoanNumber')), loanList);
            }else{
                List<Map<String, Object>> loanList = new List<Map<String, Object>>();
                loanList.add(response);
                loanMap.put(String.valueOf(response.get('ParentLoanNumber')), loanList);
            }
            // ApplicationId
            applicationIdList.add(String.valueOf(response.get('ApplicationId')));
        }
        Map<Id,List<genesis__Application_Pricing_Detail__c> > objChildLoanMap= new Map<Id,List<genesis__Application_Pricing_Detail__c>>();
        List<genesis__Application_Pricing_Detail__c>  objChildLoanList= new  List<genesis__Application_Pricing_Detail__c>();
        if(Schema.sObjectType.genesis__Application_Pricing_Detail__c.isAccessible()){
            objChildLoanList = [ SELECT  Id,genesis__Application__c,
                                        Loan_Number__c
                                FROM genesis__Application_Pricing_Detail__c
                                WHERE genesis__Application__c In :applicationIdList
                                AND genesis__Enabled_Flag__c= true];
        }
        for(genesis__Application_Pricing_Detail__c objChildLoan : objChildLoanList){
            if(objChildLoanMap.containskey(objChildLoan.genesis__Application__c)){
                objChildLoanMap.get(objChildLoan.genesis__Application__c).add(objChildLoan);
            }
            else{
                objChildLoanMap.put(objChildLoan.genesis__Application__c, new List<genesis__Application_Pricing_Detail__c>{objChildLoan});
            } 
        }
        
        for(Map<String, Object> response: responses){
            showOptions = true;
            if(type==ConstantValues.ACH){
                dom.XmlNode child = header.addChildElement('TRANSACTIONCODE',null,null);
                child.setAttribute('EffectiveDate', effectiveDate);
                child.setAttribute('LoanNumber', String.valueOf(response.get('LoanNumber')));
                child.setAttribute('Amount', String.valueOf(response.get('Amount')));
                if(response.get('CoopType') =='Growmark'){
                    child.setAttribute('Reference','ACH'+ ' - ' + String.valueOf(response.get('Reference')));
                }
                else{
                    child.setAttribute('Reference','ACH '+ String.valueOf(response.get('DealerName')) + ' - ' + String.valueOf(response.get('Reference')));
                }
                if(String.valueOf(response.get('IsClearingSuspense')).equalsIgnoreCase('True')){
                    child.setAttribute('TransactionCode','708');
                }
                else{
                    child.setAttribute('TransactionCode','100');
                }
                child.setAttribute('PaymentMethod','6');
            }
            else if(type==ConstantValues.PRODUCT_RETURN){

                dom.XmlNode child = header.addChildElement('TRANSACTIONCODE',null,null);
                child.setAttribute('EffectiveDate', effectiveDate);
                child.setAttribute('LoanNumber', String.valueOf(response.get('LoanNumber')));
                child.setAttribute('Amount', String.valueOf(response.get('Amount')));
                if(response.get('CoopType') =='Growmark'){
                    child.setAttribute('Reference','PRODUCT RETURN'+ ' - ' + String.valueOf(response.get('Reference')));
                }
                else{
                    child.setAttribute('Reference','PRODUCT RETURN '+ String.valueOf(response.get('DealerName')) + ' - ' + String.valueOf(response.get('Reference')));
                }
                child.setAttribute('TransactionCode','900');
                child.setAttribute('PaymentMethod','6');
            }
            else if(type == ConstantValues.DRAFT){
                dom.XmlNode child = header.addChildElement('TRANSACTIONCODE',null,null);
                child.setAttribute('EffectiveDate', effectiveDate);
                child.setAttribute('LoanNumber', String.valueOf(response.get('LoanNumber')));
                child.setAttribute('Amount', String.valueOf(response.get('Amount')));
                if(String.valueOf(response.get('IsClearingSuspense')).equalsIgnoreCase('True')){
                    child.setAttribute('TransactionCode','706');
                }
                else{
                    child.setAttribute('TransactionCode','704');
                }
                if(response.get('CoopType') =='Growmark'){
                    child.setAttribute('Reference','DFT'+ ' - ' + String.valueOf(response.get('Reference')));
                }
                else{
                    child.setAttribute('Reference','DFT '+ String.valueOf(response.get('DraftNumber')) + ' '+ String.valueOf(response.get('Payee')) + ' - ' + String.valueOf(response.get('Reference')));
                }
            }
            else if(type == ConstantValues.PAYMENT){
                List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
                paymentList = loanMap.get(String.valueOf(response.get('ParentLoanNumber')));
                if(paymentList.size() > 0){
                    for(Map<String, Object> payment : paymentList){
                        if(String.valueOf(payment.get('IsPayOff'))  == null  || 
                            String.valueOf(payment.get('IsPayOff')) == 'No' ){
                                showOptions = false;
                        }
                        
                    }
                }
                dom.XmlNode child = header.addChildElement('PAYMENT',null,null);
                child.setAttribute('EffectiveDate', effectiveDate);
                child.setAttribute('LoanNumber', String.valueOf(response.get('LoanNumber')));
                child.setAttribute('Amount', String.valueOf(response.get('Amount')));
                child.setAttribute('PaymentMethod','6');
                //Payment Spread ------
                child.setAttribute('PrincipalAmount', String.valueOf(response.get('PrincipalPaid')));
                child.setAttribute('InterestAmount', String.valueOf(response.get('InterestPaid')));
                child.setAttribute('FeeAmount', String.valueOf(response.get('FeesPaid')));
                //Payment Spread ------
                child.setAttribute('Reference','ONLINE PMT - '+ String.valueOf(response.get('GrowerName')));
                child.setAttribute('PaymentMethodReference','ACH-COMMERCE');
                if(showOptions == true){
                    child.setAttribute('Options','4');
                }
            }

            else if(type == ConstantValues.MOBILE_DEPOSIT){
                List<Map<String, Object>> paymentList = new List<Map<String, Object>>();
                paymentList = loanMap.get(String.valueOf(response.get('ParentLoanNumber')));
                if(paymentList.size() > 0){
                    for(Map<String, Object> payment : paymentList){
                        if(String.valueOf(payment.get('IsPayOff'))  == null  || 
                            String.valueOf(payment.get('IsPayOff')) == 'No' ){
                                showOptions = false;
                        }
                        
                    }
                }
                dom.XmlNode child = header.addChildElement(ConstantValues.PAYMENT,null,null);
                child.setAttribute('EffectiveDate', effectiveDate);
                child.setAttribute('LoanNumber', String.valueOf(response.get('LoanNumber')));
                child.setAttribute('Amount', String.valueOf(response.get('Amount')));
                child.setAttribute('PaymentMethod','2');

                // customizing body in case of overpayment, we will not send PrincipalPaid, InterestPaid & FeesPaid in case of overpayment
                Decimal totalAmountPaid = Decimal.valueOf(String.valueOf(response.get('Amount')));
                Decimal totalRemainingAmount = Decimal.valueOf(String.valueOf(response.get('PrincipalPaid')))
                                                + Decimal.valueOf(String.valueOf(response.get('InterestPaid')))
                                                + Decimal.valueOf(String.valueOf(response.get('FeesPaid'))) ;
                if(totalAmountPaid <= totalRemainingAmount ){
                //Payment Spread ------
                child.setAttribute('PrincipalAmount', String.valueOf(response.get('PrincipalPaid')));
                child.setAttribute('InterestAmount', String.valueOf(response.get('InterestPaid')));
                child.setAttribute('FeeAmount', String.valueOf(response.get('FeesPaid')));
                }

                //Payment Spread ------
                child.setAttribute('Reference','ONLINE PMT - '+ String.valueOf(response.get('GrowerName')));
                child.setAttribute('PaymentMethodReference','Check-Commerce');
                if(showOptions == true){
                    child.setAttribute('Options','4');
                }
            }
        }
        requestBody = doc.toXmlString().remove(XML_DOCTYPE);
        System.debug('Request Body =====> '+ requestBody);
        return requestBody;
    } 
    /**
     * @description This method generate the request body to book the application in NLS
     * @param requestMapping
     * @return  `String`
     * @exception 
     */
    public String bookToCoreXMLRequestbody(Map<String,Object> requestMapping){

        List<Map<String, Object>> applicationResponses = (List<Map<String, Object>>)requestMapping.get(KEY_APPLICATION);
        List<Map<String, Object>> dealerAddress = (List<Map<String, Object>>)requestMapping.get(KEY_ADDRESS);
        List<Map<String, Object>> childLoanA = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_A);
        List<Map<String, Object>> childLoanB = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_B);
        List<Map<String, Object>> childLoanC = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_C);
        List<Map<String, Object>> childLoanD = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_D);
        List<Map<String, Object>> childLoanE = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_E);
        List<Map<String, Object>> childLoanF = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_F);
        List<Map<String, Object>> childLoanG = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_G);
        List<Map<String, Object>> childLoanH = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_H);
        List<Map<String, Object>> myProgramHeader = (List<Map<String, Object>>)requestMapping.get(KEY_MY_PROGRAM);
        List<Map<String, Object>> partnerProgram = (List<Map<String, Object>>)requestMapping.get(KEY_PARTNER_PROGRAM);

        checkForNullFields(new Map<String,Object> {
                            KEY_APPLICATION_RESPONSE =>  applicationResponses,
                            KEY_DEALER_ADDRESS => dealerAddress,
                            KEY_MY_PROGRAM_HEADER => myProgramHeader});

        if(childLoanA == null){
            throw new CustomException(CustomMessageConstants.APPLICATION_NOT_SUBMITTED);
        }
        
        DOM.Document doc = new DOM.Document();
        dom.XmlNode nls = doc.createRootElement('NLS',null,null);
        this.partnerProgram = partnerProgram;

        bookToCoreParentLoanXMLRequestBody(applicationResponses, dealerAddress, partnerProgram, myProgramHeader, nls);
      
        if(childLoanA != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanA});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanA, nls);
        }
        if(childLoanB != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanB});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanB, nls);
        }
        if(childLoanC != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanC});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanC, nls);
        }
        if(childLoanD != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanD});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanD, nls);
        }
        if(childLoanE != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanE});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanE, nls);
        }
        if(childLoanF != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanF});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanF, nls);
        }
        if(childLoanG != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanG});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanG, nls);
        }
        if(childLoanH != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanH});
            bookToCoreChildLoansXMLRequestBody(applicationResponses, dealerAddress, childLoanH, nls);
        }

        dom.XmlNode transactionbody = nls.addChildElement('TRANSACTIONS', null, null);
        transactionbody.setAttribute('CommitEachTransaction', '1');
        transactionbody.setAttribute('BatchReference', '0');

        dom.XmlNode transactionCode = transactionbody.addChildElement('TRANSACTIONCODE', null, null);
        if(String.valueOf(myProgramHeader[0].get('Payer')) == 'Dealer' ){
            transactionCode.setAttribute('TransactionCode', '536');
            transactionCode.setAttribute('LoanNumber', String.valueOf(applicationResponses[0].get('LoanNumber')) +'-A');
            transactionCode.setAttribute('Reference', 'LOAN FEES PAID BY DEALER');
        }
        else{
            transactionCode.setAttribute('TransactionCode', '522');
            transactionCode.setAttribute('LoanNumber', String.valueOf(applicationResponses[0].get('LoanNumber')) +'-'+  String.valueOf(myProgramHeader[0].get('LoanNumberAdvanced')));
            transactionCode.setAttribute('Reference', 'LOAN FEES');
        }
        String dueDate = ((Datetime)applicationResponses[0].get('MaturityDate')).formatGMT('MM/dd/yyyy');
        transactionCode.setAttribute('DateDue',dueDate);
        transactionCode.setAttribute('EffectiveDate',((Datetime) System.today()).formatGMT('MM/dd/yyyy'));
        if( (applicationResponses[0].get('SigningMethod') == PortalConstants.IN_PERSON_DOCUSIGN 
                || applicationResponses[0].get('SigningMethod') == PortalConstants.EMAIL_DOCUSIGN
                || applicationResponses[0].get('SigningMethod') == ConstantValues.IN_PERSON_HYBRID) 
                && (applicationResponses[0].get('CoopType') == 'Landus' 
                || applicationResponses[0].get('CoopType') == 'Landus-Conduit')){
            transactionCode.setAttribute('Amount', '0');
        }
        else if(String.isNotBlank(String.valueOf(partnerProgram[0].get('LoanClosingFees')))){
            transactionCode.setAttribute('Amount', String.valueOf(partnerProgram[0].get('LoanClosingFees')));
        }

        requestBody = doc.toXmlString().remove(XML_DOCTYPE);         
        return requestBody;
    }

    /**
    * @description this method creates LOAN element for parent Loan
    * @author Kabir Pramanik | 12-03-2024 
    * @param applicationResponses 
    * @param dealerAddress 
    * @param partnerProgram 
    * @param myProgramHeader 
    * @param nls 
    **/
    public void bookToCoreParentLoanXMLRequestBody(List<Map<String, Object>> applicationResponses,
                                            List<Map<String, Object>> dealerAddress, 
                                            List<Map<String, Object>> partnerProgram, 
                                            List<Map<String, Object>> myProgramHeader, 
                                            dom.XmlNode nls){

        String taxIdNo;
        String shortName;
        String accountName;
        DateTime effectiveDate = Date.today();
        this.partnerProgram = partnerProgram;
        String statementCodeLabel;
        String lastDateOfMonth = ((DateTime) System.today().addMonths(1).toStartofMonth().addDays(-1)).formatGMT('MM/dd/yyyy');
        String maturityDate = ((Datetime)applicationResponses[0].get('MaturityDate')).formatGMT('MM/dd/yyyy');
        if (applicationResponses[0].get('StatementCode') == null) {
            throw new CustomException(CustomMessageConstants.STATEMENT_CODE_ERROR);
        }
        if (applicationResponses[0].get('Tier') == null) {
            throw new CustomException(CustomMessageConstants.DEALER_PRICING_TIER_MISSING);
        }
        if(String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.INDIVIDUAL
                && String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.SOLE_PROP_ENTITY){
            if (String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.INDIVIDUAL_ENTITY) {
                // dba
                taxIdNo = '';
            } else {
                // business
                taxIdNo = String.valueOf(applicationResponses[0].get('TaxId'));
                if(taxIdNo.length()==9){
                    taxIdNo = taxIdNo.substring(0,2) + '-' + taxIdNo.substring(2);
                }
                else{
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
                } 
            }
            shortName = String.valueOf(applicationResponses[0].get('AccountName'));
        }
        else{
            // individual
            taxIdNo = String.valueOf(applicationResponses[0].get('SSN'));
            if(taxIdNo.length()==9){
                taxIdNo = taxIdNo.substring(0,3) + '-' + taxIdNo.substring(3, 5) + '-' + taxIdNo.substring(5);
            }
            else{
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            shortName = String.valueOf(applicationResponses[0].get('LastName')) + ', '+ String.valueOf(applicationResponses[0].get('FirstName'));
        }
        statementCodeLabel = String.valueOf(applicationResponses[0].get('StatementCode'));
        //assigning the My Program name to 'AccountName' according to requirement
        accountName = String.valueOf(myProgramHeader[0].get('Name'));

        dom.XmlNode header = nls.addChildElement('LOAN',null,null);
        header.setAttribute('LoanTemplateName','COMMITMENT');
        header.setAttribute('LoanStatusCode','ACTIVE');
        header.setAttribute('CIFNumber',String.valueOf(applicationResponses[0].get('GrowerCIF')));
        header.setAttribute('LoanNumber',String.valueOf(applicationResponses[0].get('LoanNumber')));
        //Map for entity
        header.setAttribute('Entity',entityMap.get(String.valueOf(applicationResponses[0].get('Entity'))));
        header.setAttribute('TaxIDNumber',taxIdNo);
        header.setAttribute('ShortName',shortName);
        header.setAttribute('AccountName', accountName);
        header.setAttribute('LoanClass1Code','815-SIM');
        header.setAttribute('LoanClass2Code','NONE');
        header.setAttribute('OfficerNumber',String.valueOf(dealerAddress[0].get('DealerProdAgOfficer')));
        header.setAttribute('CollectionOfficerNumber',String.valueOf(dealerAddress[0].get('DealerPortfolioManager')));
        header.setAttribute('RiskRatingNo','14');
        header.setAttribute('OriginationDate',effectiveDate.formatGMT('MM/dd/yyyy'));
        header.setAttribute('MaturityDate',maturityDate);
        header.setAttribute('Statement1Code', statementCodeLabel);
        header.setAttribute('NextStatement1Date', lastDateOfMonth);

        dom.XmlNode loanDetail1 = header.addChildElement('LOANDETAIL1',null,null);
        loanDetail1.setAttribute('UserDefined1',String.valueOf(applicationResponses[0].get('CropYear')));
        loanDetail1.setAttribute('UserDefined2',String.valueOf(applicationResponses[0].get('Guarantee')).replace('.00', '%'));
        loanDetail1.setAttribute('UserDefined3',String.valueOf(applicationResponses[0].get('CreditRating')).toUpperCase());
        loanDetail1.setAttribute('UserDefined4',String.valueOf(applicationResponses[0].get('Tier')).toUpperCase());
        loanDetail1.setAttribute('UserDefined5',String.valueOf(applicationResponses[0].get('DealerCIF')));
        loanDetail1.setAttribute('UserDefined6',String.valueOf(dealerAddress[0].get('DealerCity')));
        loanDetail1.setAttribute('UserDefined7',String.valueOf(dealerAddress[0].get('DealerState')));
        loanDetail1.setAttribute('UserDefined9',String.valueOf(applicationResponses[0].get('Name')));

        //adding specific field for FCSA
        if (String.isNotBlank(String.valueOf(partnerProgram[0].get('UserDefined11')))) {
            loanDetail1.setAttribute('UserDefined11',String.valueOf(partnerProgram[0].get('UserDefined11')));
        }
        loanDetail1.setAttribute('UserDefined35',String.valueOf(Integer.valueOf(applicationResponses[0].get('LoanAmount'))));
        if(String.valueOf(applicationResponses[0].get('SigningMethod')).equalsIgnoreCase('Paper - Scanned')){
            loanDetail1.setAttribute('UserDefined38','PAPER');
        }
        else{
            loanDetail1.setAttribute('UserDefined38','E-DOC');
        }

        dom.XmlNode loanCreditLine = header.addChildElement('LOANCREDITLINE',null,null);
        loanCreditLine.setAttribute('Name','Main');
        loanCreditLine.setAttribute('CreditLineLimit',String.valueOf(applicationResponses[0].get('LoanAmount')));
        loanCreditLine.setAttribute('CreditTotalDrawLimit',String.valueOf(applicationResponses[0].get('CreditTotalDrawLimit')));
        loanCreditLine.setAttribute('OverdrawThresholdAmount','');
        
        dom.XmlNode loantoCifRelationship = header.addChildElement('LOANTOCIFRELATIONSHIP',null,null);
        loantoCifRelationship.setAttribute('RelatedCIFNumber',String.valueOf(applicationResponses[0].get('DealerCIF')));
        loantoCifRelationship.setAttribute('RelationshipCode','CO-OP');
    }

    /**
     * @description This method used to generate the request body for the child loan
     * @param applicationResponses 
     * @param dealerAddress 
     * @param childLoanB 
     * @param nls 
     * @exception 
     */
    public void bookToCoreChildLoansXMLRequestBody(List<Map<String, Object>> applicationResponses,
                                                List<Map<String, Object>> dealerAddress, 
                                                List<Map<String, Object>> childLoanB,
                                                dom.XmlNode nls){

        String maturityDate = ((Datetime)applicationResponses[0].get('MaturityDate')).formatGMT('MM/dd/yyyy');
        Boolean hasBillingDate = childLoanB[0].get('hasBillingDate')!=null? Boolean.valueOf(childLoanB[0].get('hasBillingDate')): false;
        String billingDate = hasBillingDate?((Datetime)childLoanB[0].get('billingDate')).formatGMT('MM/dd/yyyy'):maturityDate;
        String setLoanTemplate = hasBillingDate?'INPUTFLEX1':'INPUTFLEX';

        Decimal cropYear = Decimal.valueOf(String.valueOf(applicationResponses[0].get('CropYear')));
        String baseRateName;
        if(cropYear < NEW_RATE_CARD_YEAR){
            baseRateName = '4-CFA ADVANTAGE';    
        }else{
            baseRateName = String.valueOf(partnerProgram[0].get('BaseRateName'));
        } 
        DateTime effectiveDate = Date.today();
        String taxIdNo;
        Boolean isVariable;
        String shortName = '';

        //LOAN element specific to every tranche
        dom.XmlNode loanChildHeaderB = nls.addChildElement('LOAN',null,null);
        loanChildHeaderB.setAttribute('LoanTemplateName',setLoanTemplate);
        loanChildHeaderB.setAttribute('LoanStatusCode','ACTIVE');
        loanChildHeaderB.setAttribute('CIFNumber',String.valueOf(applicationResponses[0].get('GrowerCIF')));
        loanChildHeaderB.setAttribute('MasterNoteLoanNumber',String.valueOf(applicationResponses[0].get('LoanNumber')));
        loanChildHeaderB.setAttribute('LoanNumber',String.valueOf(childLoanB[0].get('LoanNumber')));
        //Add entity Check
        loanChildHeaderB.setAttribute('Entity',entityMap.get(String.valueOf(applicationResponses[0].get('Entity'))));
        //modularise TIN/SSN
        if(String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.INDIVIDUAL
                        && String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.SOLE_PROP_ENTITY){

            if (String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.INDIVIDUAL_ENTITY) {
                // dba 
                taxIdNo = '';
            } else {
                // business
                taxIdNo = String.valueOf(applicationResponses[0].get('TaxId'));
                if(taxIdNo.length()==9){
                    taxIdNo = taxIdNo.substring(0,2) + '-' + taxIdNo.substring(2);
                }
                else{
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
                }  
            }
            shortName = String.valueOf(applicationResponses[0].get('AccountName'));
        }
        else{
            // individual
            taxIdNo = String.valueOf(applicationResponses[0].get('SSN'));
            if(taxIdNo.length()==9){
                taxIdNo = taxIdNo.substring(0,3) + '-' + taxIdNo.substring(3, 5) + '-' + taxIdNo.substring(5);
            }
            else{
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            shortName = String.valueOf(applicationResponses[0].get('LastName')) + ', '+ String.valueOf(applicationResponses[0].get('FirstName'));
        }
        loanChildHeaderB.setAttribute('TaxIDNumber',taxIdNo);
        loanChildHeaderB.setAttribute('ShortName',shortName);
        loanChildHeaderB.setAttribute('AccountName',String.valueOf(childLoanB[0].get('Description')));
        loanChildHeaderB.setAttribute('LoanClass1Code','815-SIM');
        if((Decimal)childLoanB[0].get('Subsidy') > 0){
            loanChildHeaderB.setAttribute('LoanClass2Code','SUBSIDY'); 
        }
        else if((Decimal)childLoanB[0].get('Premium') > 0){
            loanChildHeaderB.setAttribute('LoanClass2Code','PREMIUM'); 
        }
        else{
            loanChildHeaderB.setAttribute('LoanClass2Code','NONE');
        }
        loanChildHeaderB.setAttribute('OfficerNumber',String.valueOf(dealerAddress[0].get('DealerProdAgOfficer')));
        loanChildHeaderB.setAttribute('CollectionOfficerNumber',String.valueOf(dealerAddress[0].get('DealerPortfolioManager')));
        loanChildHeaderB.setAttribute('RiskRatingNo','14');
        loanChildHeaderB.setAttribute('OriginationDate',effectiveDate.formatGMT('MM/dd/yyyy'));
        loanChildHeaderB.setAttribute('FirstPrincipalPaymentDate',billingDate);
        loanChildHeaderB.setAttribute('FirstInterestPaymentDate',billingDate);
        loanChildHeaderB.setAttribute('MaturityDate',maturityDate);

        dom.XmlNode childLoanDetail1B = loanChildHeaderB.addChildElement('LOANDETAIL1',null,null);
        childLoanDetail1B.setAttribute('UserDefined1',String.valueOf(applicationResponses[0].get('CropYear')));
        childLoanDetail1B.setAttribute('UserDefined2',String.valueOf(applicationResponses[0].get('Guarantee')).replace('.00', '%'));
        childLoanDetail1B.setAttribute('UserDefined3',String.valueOf(applicationResponses[0].get('CreditRating')).toUpperCase());
        childLoanDetail1B.setAttribute('UserDefined5',String.valueOf(applicationResponses[0].get('DealerCIF')));
        childLoanDetail1B.setAttribute('UserDefined6',String.valueOf(dealerAddress[0].get('DealerCity')));
        childLoanDetail1B.setAttribute('UserDefined7',String.valueOf(dealerAddress[0].get('DealerState')));
        childLoanDetail1B.setAttribute('UserDefined9',String.valueOf(applicationResponses[0].get('Name')));
        //adding specific field for FCSA
        if (String.isNotBlank(String.valueOf(partnerProgram[0].get('UserDefined11')))) {
            childLoanDetail1B.setAttribute('UserDefined11',String.valueOf(partnerProgram[0].get('UserDefined11')));
        }
        childLoanDetail1B.setAttribute('UserDefined35',String.valueOf(Integer.valueOf(applicationResponses[0].get('LoanAmount'))));
        if(String.valueOf(applicationResponses[0].get('SigningMethod')).equalsIgnoreCase('Paper - Scanned')){
            childLoanDetail1B.setAttribute('UserDefined38','PAPER');
        }
        else{
            childLoanDetail1B.setAttribute('UserDefined38','E-DOC');
        }

        dom.XmlNode childLoanCreditLineB = loanChildHeaderB.addChildElement('LOANCREDITLINE',null,null);
        childLoanCreditLineB.setAttribute('Name','Main');
        childLoanCreditLineB.setAttribute('CreditLineLimit','0');
        childLoanCreditLineB.setAttribute('CreditTotalDrawLimit','0');
        childLoanCreditLineB.setAttribute('OverdrawThresholdAmount','');

        //LOANPARTICIPANT element for CFA participation
        dom.XmlNode childLoanParticipantCfaB = loanChildHeaderB.addChildElement('LOANPARTICIPANT',null,null);
        childLoanParticipantCfaB.setAttribute('ParticipantNumber','PRIMARY');
        childLoanParticipantCfaB.setAttribute('ParticipantName','CFA');
        childLoanParticipantCfaB.setAttribute('LoanGroupName','INPUT');

        dom.XmlNode childLoanSubsidyPremium = childLoanParticipantCfaB.addChildElement('PARTICIPANTRULE',null,null);
        childLoanSubsidyPremium.setAttribute('RuleName','InterestPayment%');
        childLoanSubsidyPremium.setAttribute('RuleValue','100.00000');

        //LOANPARTICIPANT element for Dealer participation
        dom.XmlNode childLoanParticipantDealerB = loanChildHeaderB.addChildElement('LOANPARTICIPANT',null,null);
        childLoanParticipantDealerB.setAttribute('ParticipantNumber','8'+ String.valueOf(childLoanB[0].get('LoanNumber'))); // 8 + loan number
        childLoanParticipantDealerB.setAttribute('ParticipantName',String.valueOf(dealerAddress[0].get('DealerCity')) +', '+ String.valueOf(dealerAddress[0].get('DealerState')));// city, state 
        String interestTypeValue;
        // if((Decimal)childLoanB[0].get('Subsidy') == 0){ 
        //     childLoanParticipantDealerB.setAttribute('LoanGroupName','PREMIUM');
        // }
        // else if((Decimal)childLoanB[0].get('Premium') == 0){
        //     childLoanParticipantDealerB.setAttribute('LoanGroupName','SUBSIDY');
        // }
        if(cropYear < NEW_RATE_CARD_YEAR){
            if(Decimal.ValueOf(String.valueOf(childLoanB[0].get('cfaAdvantageRate'))) < Decimal.ValueOf(String.valueOf(childLoanB[0].get('InterestRate')))){
                interestTypeValue = '4';
                childLoanParticipantDealerB.setAttribute('LoanGroupName','PREMIUM');
            }
            else {
                interestTypeValue = '5';
                childLoanParticipantDealerB.setAttribute('LoanGroupName','SUBSIDY');
            }
        }else{
            if(Decimal.ValueOf(String.valueOf(partnerProgram[0].get('BaseRateValue'))) < Decimal.ValueOf(String.valueOf(childLoanB[0].get('InterestRate')))){
                interestTypeValue = '4';
                childLoanParticipantDealerB.setAttribute('LoanGroupName','PREMIUM');
            }
            else {
                interestTypeValue = '5';
                childLoanParticipantDealerB.setAttribute('LoanGroupName','SUBSIDY');
            }
        }

        dom.XmlNode childLoanParticipantInterestRateRecordDealerB1 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordDealerB1.setAttribute('InterestRate','0.00');
        Integer totalDays = 0;
        String cfaBaseRateAdjuster = '';
        String growerBaseRateAdjuster = '';
        for(Map<String,Object> childLoan : childLoanB){
            if(System.today().daysBetween(Date.ValueOf(childLoan.get('EndDate'))) > 0){
                if((Decimal)childLoan.get('Subsidy') == 0){
                    interestTypeValue = '4';
                }
                else if((Decimal)childLoan.get('Premium') == 0){
                    interestTypeValue = '5';
                }
                isVariable = String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable');

                dom.XmlNode childLoanInterestRateRecord1 = loanChildHeaderB.addChildElement('LOANINTERESTRATERECORD',null,null);
                childLoanInterestRateRecord1.setAttribute('InterestType','0');
                childLoanInterestRateRecord1.setAttribute('StepType','1');
                if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                    childLoanInterestRateRecord1.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                }
                else{
                    childLoanInterestRateRecord1.setAttribute('StepDaysFrom','1');
                }
                /*if(Date.ValueOf(childLoan.get('EndDate'))==(Date)applicationResponses[0].get('MaturityDate')){
                    childLoanInterestRateRecord1.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 5));
                }
                else{*/
                    childLoanInterestRateRecord1.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 1));

                //  } 
                childLoanInterestRateRecord1.setAttribute('CapRate','100');
                if(String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable')){
                    if(cropYear < NEW_RATE_CARD_YEAR){
                        growerBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('InterestRate')))-Decimal.ValueOf(String.valueOf(childLoan.get('cfaAdvantageRate'))));
                    }else{
                        growerBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('InterestRate')))-Decimal.ValueOf(String.valueOf(partnerProgram[0].get('BaseRateValue'))));
                    }
                    childLoanInterestRateRecord1.setAttribute('BaseRateAdjuster',growerBaseRateAdjuster);
                    childLoanInterestRateRecord1.setAttribute('BaseRateName',baseRateName);
                    childLoanInterestRateRecord1.setAttribute('InitialRateChangeType','1');
                    childLoanInterestRateRecord1.setAttribute('InitialRateChangeNumberofPeriods','1');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangeType','5');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangeNumberofPeriods','1');
                    childLoanInterestRateRecord1.setAttribute('InitialRateChangePeriod','DA');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangePeriod','DA');
                }
                else{
                    growerBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('InterestRate'))));
                    childLoanInterestRateRecord1.setAttribute('InterestRate',growerBaseRateAdjuster);
                }

                dom.XmlNode childLoanParticipantInterestRateRecordCfa = childLoanParticipantCfaB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
                childLoanParticipantInterestRateRecordCfa.setAttribute('InterestType','0');
                childLoanParticipantInterestRateRecordCfa.setAttribute('StepType','1');
                if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                    childLoanParticipantInterestRateRecordCfa.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')))+1));
                }
                else{
                    childLoanParticipantInterestRateRecordCfa.setAttribute('StepDaysFrom','1');
                }
                childLoanParticipantInterestRateRecordCfa.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate')))+1));
                cfaBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('CfaParticipation'))) * -1);
                childLoanParticipantInterestRateRecordCfa.setAttribute('BaseRateAdjuster',cfaBaseRateAdjuster);
                childLoanParticipantInterestRateRecordCfa.setAttribute('InitialRateChangePeriod','DA');
                childLoanParticipantInterestRateRecordCfa.setAttribute('SubsequentRateChangePeriod','DA');
                childLoanParticipantInterestRateRecordCfa.setAttribute('CapRate','100');
                childLoanParticipantInterestRateRecordCfa.setAttribute('BaseRateName',baseRateName);
                childLoanParticipantInterestRateRecordCfa.setAttribute('InitialRateChangeType','1');
                childLoanParticipantInterestRateRecordCfa.setAttribute('InitialRateChangeNumberofPeriods','1');
                childLoanParticipantInterestRateRecordCfa.setAttribute('SubsequentRateChangeType','5');
                childLoanParticipantInterestRateRecordCfa.setAttribute('SubsequentRateChangeNumberofPeriods','1'); 
                if(Date.ValueOf(childLoan.get('EndDate'))==(Date)applicationResponses[0].get('MaturityDate')){        
                    dom.XmlNode childLoanParticipantInterestRateRecordDealer22 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestType',interestTypeValue); //4=Premium, 5=subsidy
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('StepType','1');
                    //childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom', String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                    if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                    }
                    else{
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom','1');
                    }
                    
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 5));
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('CapRate','100');
                    if(String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable')){
                        if(interestTypeValue == '4'){
                            childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))));
                        }
                        else{
                            childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))));
                        }
                    }
                    else{
                        if(interestTypeValue == '4'){
                            if(cropYear < NEW_RATE_CARD_YEAR){
                                childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))-Decimal.ValueOf(String.valueOf(childLoan.get('cfaAdvantageRate')))));
                            }else{
                                childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))-Decimal.ValueOf(String.valueOf(partnerProgram[0].get('BaseRateValue')))));
                            }
                        }
                        else{
                            if(cropYear < NEW_RATE_CARD_YEAR){
                                childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))-Decimal.ValueOf(String.valueOf(childLoan.get('cfaAdvantageRate')))));
                            }else{
                                childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))-Decimal.ValueOf(String.valueOf(partnerProgram[0].get('BaseRateValue')))));
                            }
                        }
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateName',baseRateName);
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('InitialRateChangeType','1');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('InitialRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('SubsequentRateChangeType','5');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('SubsequentRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('InitialRateChangePeriod','DA');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('SubsequentRateChangePeriod','DA');
                    }
                }
                else{
                    dom.XmlNode childLoanParticipantInterestRateRecordDealer2 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('InterestType',interestTypeValue); //4=Premium, 5=subsidy
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('StepType','1');
                    if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                    }
                    else{
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('StepDaysFrom','1');
                    }
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 1));
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('CapRate','100');
                    if(String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable')){
                        if(interestTypeValue == '4'){
                            childLoanParticipantInterestRateRecordDealer2.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))));
                        }
                        else{
                            childLoanParticipantInterestRateRecordDealer2.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))));
                        }
                    }
                    else{
                        if(interestTypeValue == '4'){
                            if(cropYear < NEW_RATE_CARD_YEAR){
                                childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))-Decimal.ValueOf(String.valueOf(childLoan.get('cfaAdvantageRate')))));
                            }else{
                                childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))-Decimal.ValueOf(String.valueOf(partnerProgram[0].get('BaseRateValue')))));
                            }
                        }
                        else{
                            if(cropYear < NEW_RATE_CARD_YEAR){
                                childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))-Decimal.ValueOf(String.valueOf(childLoan.get('cfaAdvantageRate')))));
                            }else{
                                childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))-Decimal.ValueOf(String.valueOf(partnerProgram[0].get('BaseRateValue')))));
                            }
                        }
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateName',baseRateName);
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('InitialRateChangeType','1');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('InitialRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('SubsequentRateChangeType','5');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('SubsequentRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('InitialRateChangePeriod','DA');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('SubsequentRateChangePeriod','DA');
                    }
                }
                totalDays = Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 1;
            }
        }
    
        dom.XmlNode childLoanInterestRateRecord2 = loanChildHeaderB.addChildElement('LOANINTERESTRATERECORD',null,null);
        childLoanInterestRateRecord2.setAttribute('InterestType','1');
        childLoanInterestRateRecord2.setAttribute('StepType','1');
        childLoanInterestRateRecord2.setAttribute('StepDaysFrom','1');
        childLoanInterestRateRecord2.setAttribute('StepDaysTo','5');
        childLoanInterestRateRecord2.setAttribute('CapRate','100');
        if(isVariable){
            childLoanInterestRateRecord2.setAttribute('BaseRateAdjuster',growerBaseRateAdjuster);
            childLoanInterestRateRecord2.setAttribute('BaseRateName',baseRateName);
            childLoanInterestRateRecord2.setAttribute('InitialRateChangeType','1');
            childLoanInterestRateRecord2.setAttribute('InitialRateChangeNumberofPeriods','1');
            childLoanInterestRateRecord2.setAttribute('SubsequentRateChangeType','5');
            childLoanInterestRateRecord2.setAttribute('SubsequentRateChangeNumberofPeriods','1');
            childLoanInterestRateRecord2.setAttribute('InitialRateChangePeriod','DA');
            // childLoanInterestRateRecord2.setAttribute('SubsequentRateChangeType','5');
            childLoanInterestRateRecord2.setAttribute('SubsequentRateChangePeriod','DA');
        }
        else{
            childLoanInterestRateRecord2.setAttribute('InterestRate',growerBaseRateAdjuster);
        }

        dom.XmlNode childLoanInterestRateRecord3 = loanChildHeaderB.addChildElement('LOANINTERESTRATERECORD',null,null);
        childLoanInterestRateRecord3.setAttribute('InterestType','1');
        childLoanInterestRateRecord3.setAttribute('StepType','1');
        childLoanInterestRateRecord3.setAttribute('StepDaysFrom','6');
        childLoanInterestRateRecord3.setAttribute('StepDaysTo','6');
        childLoanInterestRateRecord3.setAttribute('BaseRateName',baseRateName);
        childLoanInterestRateRecord3.setAttribute('BaseRateAdjuster',String.valueOf(partnerProgram[0].get('BaseRateAdjuster')));
        childLoanInterestRateRecord3.setAttribute('InitialRateChangeType','1');
        childLoanInterestRateRecord3.setAttribute('InitialRateChangePeriod','DA');
        childLoanInterestRateRecord3.setAttribute('InitialRateChangeNumberofPeriods','1');
        childLoanInterestRateRecord3.setAttribute('SubsequentRateChangeType','5');
        childLoanInterestRateRecord3.setAttribute('SubsequentRateChangePeriod','DA');
        childLoanInterestRateRecord3.setAttribute('SubsequentRateChangeNumberofPeriods','1');
        childLoanInterestRateRecord3.setAttribute('CapRate','100');

        dom.XmlNode childLoanParticipantInterestRateRecordCfa11 = childLoanParticipantCfaB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InterestType','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('StepType','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('StepDaysFrom','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('StepDaysTo','5');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('BaseRateAdjuster', cfaBaseRateAdjuster);
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InitialRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('SubsequentRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('CapRate','100');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('BaseRateName',baseRateName);
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InitialRateChangeType','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InitialRateChangeNumberofPeriods','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('SubsequentRateChangeType','5');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('SubsequentRateChangeNumberofPeriods','1');

        dom.XmlNode childLoanParticipantInterestRateRecordCfa12 = childLoanParticipantCfaB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InterestType','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('StepType','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('StepDaysFrom','6');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('StepDaysTo','6');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('BaseRateAdjuster',String.valueOf(partnerProgram[0].get('BaseRateAdjuster')));
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InitialRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('SubsequentRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('CapRate','100');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('BaseRateName',baseRateName);
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InitialRateChangeType','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InitialRateChangeNumberofPeriods','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('SubsequentRateChangeType','5');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('SubsequentRateChangeNumberofPeriods','1');

        dom.XmlNode childLoanParticipantInterestRateRecordDealer22 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestType',interestTypeValue); //4=Premium, 5=subsidy
        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepType','1');
        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom', String.valueOf(totalDays + 5));
        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysTo', String.valueOf(totalDays + 5));
        childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestRate','0.00');
        childLoanParticipantInterestRateRecordDealer22.setAttribute('CapRate','100');

        dom.XmlNode childLoantoCifRelationshipB = loanChildHeaderB.addChildElement('LOANTOCIFRELATIONSHIP',null,null);
        childLoantoCifRelationshipB.setAttribute('RelatedCIFNumber',String.valueOf(applicationResponses[0].get('DealerCIF')));
        childLoantoCifRelationshipB.setAttribute('RelationshipCode','CO-OP');
    }
    /**
     * @description This method is used to generate the request body to book a loan
     * @param applicationResponses 
     * @param applicantResponse 
     * @return  `String`
     * @exception 
     */
    public String bookToCoreCIFXMLRequestbody(List<Map<String, Object>> applicationResponses, List<Map<String, Object>> applicantResponse, List<Map<String, Object>> borrowerDetailResponse){

        String taxIdNo;
        String shortName;
        String socialSecurityNumber;
        DOM.Document doc = new DOM.Document();
        dom.XmlNode nls = doc.createRootElement('NLS',null,null);
        dom.XmlNode header = nls.addChildElement('CIF',null,null);
        header.setAttribute('CIFPortfolioName','BORROWERS');
        header.setAttribute('CIFNumber',String.valueOf(applicationResponses[0].get('GrowerCIF')));
        header.setAttribute('Entity',entityMap.get(String.valueOf(applicationResponses[0].get('Entity'))));

        if (String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.SOLE_PROP_ENTITY 
            || String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.INDIVIDUAL) {
            // individual sole-prop entity
            taxIdNo = String.valueOf(applicationResponses[0].get('SSN'));
            if(taxIdNo.length()==9){
                taxIdNo = taxIdNo.substring(0,3) + '-' + taxIdNo.substring(3, 5) + '-' + taxIdNo.substring(5);
            }
            else{
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }

        } else {
            if (String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.INDIVIDUAL_ENTITY) {
                // business entity
                taxIdNo = String.valueOf(applicationResponses[0].get('TaxId'));
                if(taxIdNo.length()==9){
                    taxIdNo = taxIdNo.substring(0,2) + '-' + taxIdNo.substring(2);
                }
                else{
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
                } 
    
            } else {
                taxIdNo = '';
            }
        }
       
        
        header.setAttribute('MiddleName1',String.valueOf(applicationResponses[0].get('MiddleName'))!=null ? String.valueOf(applicationResponses[0].get('MiddleName')) : '' );
        header.setAttribute('Suffix1',String.valueOf(borrowerDetailResponse[0].get('Suffix'))==null ? '' : String.valueOf(borrowerDetailResponse[0].get('Suffix')));
        header.setAttribute('Title1',String.valueOf(borrowerDetailResponse[0].get('Title'))!=null ? String.valueOf(borrowerDetailResponse[0].get('Title')) : '' );

        header.setAttribute('StreetAddress1',String.valueOf(borrowerDetailResponse[0].get('Street')) == null ? '' : String.valueOf(borrowerDetailResponse[0].get('Street')));
        header.setAttribute('City',String.valueOf(borrowerDetailResponse[0].get('City')) == null ? '' : String.valueOf(borrowerDetailResponse[0].get('City')));
        header.setAttribute('State',String.valueOf(borrowerDetailResponse[0].get('State')) == null ? '' : String.valueOf(borrowerDetailResponse[0].get('State')));
        header.setAttribute('ZipCode',String.valueOf(borrowerDetailResponse[0].get('PostalCode')) == null ? '' : String.valueOf(borrowerDetailResponse[0].get('PostalCode')));
        if(applicationResponses[0].get('Email') != null){
            header.setAttribute('EmailAddress1',String.valueOf(applicationResponses[0].get('Email')));
        }
        header.setAttribute('OfficerNumber', String.valueOf(applicationResponses[0].get('DealerProdAgOfficer')));
        dom.XmlNode cifPhoneNo = header.addChildElement('CIFPHONENUMBER',null,null);
        cifPhoneNo.setAttribute('PhoneDescription',String.valueOf(applicationResponses[0].get('Description'))!=null ? String.valueOf(applicationResponses[0].get('Description')) : '' );
        cifPhoneNo.setAttribute('DoNotCallFlag',String.valueOf(applicationResponses[0].get('DoNotCall')) == 'false' ? '0' : '1' );
        if(String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.INDIVIDUAL
                            && String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.SOLE_PROP_ENTITY){

            // for company / dba
            header.setAttribute('CompanyName',String.valueOf(applicationResponses[0].get('AccountName')));
            if(String.valueOf(borrowerDetailResponse[0].get('Phone')) != null){
                cifPhoneNo.setAttribute('PhoneNumber',String.valueOf(borrowerDetailResponse[0].get('Phone')));
            }
            header.setAttribute('LastName1',String.valueOf(applicantResponse[0].get('PrimaryApplicantLastName')));
            header.setAttribute('FirstName1',String.valueOf(applicantResponse[0].get('PrimaryApplicantFirstName')));
         
            socialSecurityNumber = String.valueOf(applicantResponse[0].get('SSN'));
            socialSecurityNumber = socialSecurityNumber.substring(0,3) + '-' + socialSecurityNumber.substring(3, 5) + '-' + socialSecurityNumber.substring(5);
            header.setAttribute('TaxIDNumber2',socialSecurityNumber);
            
            if (String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.INDIVIDUAL_ENTITY) {
                header.setAttribute('TaxIDNumber', '');
            } else {
                header.setAttribute('TaxIDNumber', taxIdNo);
            }
            
            header.setAttribute('ShortName',String.valueOf(applicationResponses[0].get('AccountName')));

        }
        else{
            // for individual
            header.setAttribute('CompanyName','');
            if(borrowerDetailResponse[0].get('Phone') != null){
                cifPhoneNo.setAttribute('PhoneNumber',String.valueOf(borrowerDetailResponse[0].get('Phone')));
            }
            header.setAttribute('LastName1',String.valueOf(applicationResponses[0].get('LastName')));
            header.setAttribute('FirstName1',String.valueOf(applicationResponses[0].get('FirstName')));
            header.setAttribute('TaxIDNumber2','');
            shortName = String.valueOf(applicationResponses[0].get('LastName')) + ', '+ String.valueOf(applicationResponses[0].get('FirstName'));
            header.setAttribute('ShortName',shortName);
            header.setAttribute('TaxIDNumber', taxIdNo);
        }
        requestBody = doc.toXmlString().remove('<?xml version="1.0" encoding="UTF-8"?>');
        return requestBody;
    }
    /**
    * @description This method is used to check the required field for the application , dealer address, pricing and myProgram
    * @author Kabir Pramanik | 12-06-2024 
    * @param paramForValidationMap 
    **/
    public void checkForNullFields(Map<String, Object> paramForValidationMap){
        List<Map<String,Object>> applicationReponseList;
        List<Map<String,Object>> dealerAddressList;
        List<Map<String,Object>> pricingDetailsList;
        List<Map<String,Object>> myProgram;

        //Handling error for the Application Fields
        if(paramForValidationMap.containsKey(KEY_APPLICATION_RESPONSE)){
            applicationReponseList = (List<Map<String,Object>>)paramForValidationMap.get(KEY_APPLICATION_RESPONSE);
            if(applicationReponseList[0].get('GrowerCIF') == null){
                throw new CustomException(CustomMessageConstants.GROWER_CIF_MISSING);
            }
            if(applicationReponseList[0].get('DealerCIF') == null){
                throw new CustomException(CustomMessageConstants.DEALER_CIF_MISSING);
            }
            if(applicationReponseList[0].get('LoanNumber') == null){
                throw new CustomException(CustomMessageConstants.LOAN_NUMBER_MISSING);
            }
            if(applicationReponseList[0].get('Entity') == null){
                throw new CustomException(CustomMessageConstants.APPLICATION_ENTITY_MISSING);
            }
            if (String.valueOf(applicationReponseList[0].get('Entity')) == PortalConstants.INDIVIDUAL
                || String.valueOf(applicationReponseList[0].get('Entity')) == PortalConstants.SOLE_PROP_ENTITY) {
                
                if(applicationReponseList[0].get('SSN') == null){
                    throw new CustomException(CustomMessageConstants.GROWER_SSN_MISSING);
                }
    
            } else if (String.valueOf(applicationReponseList[0].get('Entity')) != PortalConstants.INDIVIDUAL_ENTITY) {
                // business
                if(applicationReponseList[0].get('TaxId') == null){
                    throw new CustomException(CustomMessageConstants.GROWER_TAXID_MISSING);
                }
                
            } 
            if(applicationReponseList[0].get('AccountName') == null){
                throw new CustomException(CustomMessageConstants.GROEWR_ACCOUNT_NAME_MISSING);
            }
            if(applicationReponseList[0].get('MaturityDate') == null){
                throw new CustomException(CustomMessageConstants.MATURITY_DATE_MISSING);
            }
            if(applicationReponseList[0].get('CropYear') == null){
                throw new CustomException(CustomMessageConstants.CROP_YEAR_MISSING);
            }
            if(applicationReponseList[0].get('Guarantee') == null){
                throw new CustomException(CustomMessageConstants.APPLICATION_GURANTEE_MISSING);
            }
            if(applicationReponseList[0].get('LoanAmount') == null){
                throw new CustomException(CustomMessageConstants.APPLICATION_LOAN_AMOUNT_MISSING);
            }
            if(applicationReponseList[0].get('CreditTotalDrawLimit') == null){
                throw new CustomException(CustomMessageConstants.CREDIT_TOTAL_DRAW_LIMIT_MISSING);
            }
            if(applicationReponseList[0].get('SigningMethod') == null){
                throw new CustomException(CustomMessageConstants.SIGNING_METHOD_MISSING);
            }
            if(applicationReponseList[0].get('CreditRating') == null){
                throw new CustomException(CustomMessageConstants.CREDIT_RATING_MISSING);
            }
        }

        //Handling error for the Dealer address Fields
        if(paramForValidationMap.containsKey(KEY_DEALER_ADDRESS)){
            dealerAddressList = (List<Map<String,Object>>)paramForValidationMap.get(KEY_DEALER_ADDRESS);
            if(dealerAddressList[0].get('DealerAccount') == null){
                throw new CustomException(CustomMessageConstants.DEALER_ACCOUNT_MISSING);
            }
            if(dealerAddressList[0].get('DealerCity') == null){
                throw new CustomException(CustomMessageConstants.DEALER_CITY_MISSING);
            }
            if(dealerAddressList[0].get('DealerState') == null){
                throw new CustomException(CustomMessageConstants.DEALER_STATE_MISSING);
            }
            if(dealerAddressList[0].get('DealerPortfolioManager') == null){
                throw new CustomException(CustomMessageConstants.DEALER_PORTFOLIO_MANAGER_MISSING);
            }
            if(dealerAddressList[0].get('DealerProdAgOfficer') == null){
                throw new CustomException(CustomMessageConstants.DEALER_PROD_AG_OFFICER_MISSING);
            }
        }

        //Handling errors for Pricing Details fields
        if(paramForValidationMap.containsKey(KEY_PRICING_DETAILS)){
            pricingDetailsList = (List<Map<String,Object>>)paramForValidationMap.get(KEY_PRICING_DETAILS);
            for(Map<String, Object> eachPricing: pricingDetailsList){
                if(eachPricing.get('Id') == null){
                    throw new CustomException(CustomMessageConstants.APPLICATION_NOT_SUBMITTED);
                }
                if(eachPricing.get('LoanNumber') == null){
                    throw new CustomException(CustomMessageConstants.CHILD_LOAN_NUMBER_MISSING);
                }
                if(eachPricing.get('Description') == null){
                    throw new CustomException(CustomMessageConstants.LOAN_DESCRIPTION_MISSING);
                }
                if(eachPricing.get('InterestRate') == null){
                    throw new CustomException(CustomMessageConstants.INTEREST_RATE_MISSING);
                }
                if(eachPricing.get('InterestType') == null){
                    throw new CustomException(CustomMessageConstants.INTEREST_RATE_TYPE_MISSING);
                }
                if(eachPricing.get('CfaParticipation') == null){
                    throw new CustomException(CustomMessageConstants.CFA_PARTICIPATION_RATE_MISSING);
                }
                if(eachPricing.get('StartDate') == null){
                    throw new CustomException(CustomMessageConstants.START_DATE_MISSING);
                }
                if(eachPricing.get('EndDate') == null){
                    throw new CustomException(CustomMessageConstants.END_DATE_MISSING);
                }
            }
        }
       
        //Error messages on my program fields
        if(paramForValidationMap.containsKey(KEY_MY_PROGRAM_HEADER)){
            myProgram = (List<Map<String,Object>>)paramForValidationMap.get(KEY_MY_PROGRAM_HEADER);
            if(myProgram == null){
                throw new CustomException(CustomMessageConstants.MY_PROGRAM_MISSING);
            }
            // if(myProgram[0].get('closingFee') == null){
            //     throw new CustomException('My Program Closing Fee is missing');
            // }
            if(myProgram[0].get('Payer') == null){
                throw new CustomException(CustomMessageConstants.PAYER_MISSING);
            }
            if(myProgram[0].get('EffectiveDate') == null){
                throw new CustomException(CustomMessageConstants.EFFECTIVE_DATE_MISSING);
            }
            //check If the payer is Grower
            if(myProgram[0].get('Payer') == 'Grower'){
                //then there must be a loan fee advanced on
                if(myProgram[0].get('LoanNumberAdvanced') == null){
                    throw new CustomException(CustomMessageConstants.LOAN_NUMBER_ADVANCED_ON_MISSING);
                }
            }
        }
    }

    /**
     * @description This method is used to generate the request body for updating the statement code in NLS
     * @param loans 
     * @param statementCodesMap 
     * @return  `String`
     * @exception 
     */
    public static String generateXmlDocument(List<Map<String, Object>> loans, Map<String, Object> statementCodesMap) {

        String statementCodeLabel;

        Dom.Document doc = new DOM.Document();
        Dom.XmlNode nlsNode = doc.createRootElement(NLS, null, null);
        
        for (Map<String, Object> activeLoan : loans) {
            Dom.XmlNode loanNode = nlsNode.addChildElement(LOAN, null, null);

            loanNode.setAttribute(LOAN_NUMBER, (String) activeLoan.get(KEY_LOAN_NUM));
            loanNode.setAttribute(UPDATE_FLAG, '1');

            if (activeLoan.get(KEY_PRICING_COUNT) == 1) {
                // single rate loan
                // if (!activeLoan.containsKey(KEY_COOP_TYPE)) {
                //     throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
                // }
                if(String.valueOf(activeLoan.get(KEY_COOP_TYPE)) == ConstantValues.GROWMARK_COOP_TYPE){
                    statementCodeLabel = String.valueOf(activeLoan.get(KEY_COOP_TYPE)).toUpperCase() + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX;
                    loanNode.setAttribute(STATEMENT_ONE_CODE, ((Statement_Code__mdt)statementCodesMap.get(statementCodeLabel)).Opt_In_Code__c);
                } else {
                    statementCodeLabel = String.valueOf(activeLoan.get(KEY_PARTNER_PROGRAM)).toUpperCase() + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX;
                    loanNode.setAttribute(STATEMENT_ONE_CODE, ((CFA_Partner_Program__c)statementCodesMap.get(statementCodeLabel)).Statement_Code_Single_Rate_Opt_In__c);
                }
                

                // if (!statementCodesMap.containsKey(statementCodeLabel)) {
                //     throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
                // }                
            } else {
                // multi rate loan
                // if (!activeLoan.containsKey(KEY_COOP_TYPE)) {
                //     throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
                // }
                if(String.valueOf(activeLoan.get(KEY_COOP_TYPE)) == ConstantValues.GROWMARK_COOP_TYPE){
                    statementCodeLabel = String.valueOf(activeLoan.get(KEY_COOP_TYPE)).toUpperCase() + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX;
                    loanNode.setAttribute(STATEMENT_ONE_CODE, ((Statement_Code__mdt)statementCodesMap.get(statementCodeLabel)).Opt_In_Code__c);
                } else {
                    statementCodeLabel = String.valueOf(activeLoan.get(KEY_PARTNER_PROGRAM)).toUpperCase() + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX;
                    loanNode.setAttribute(STATEMENT_ONE_CODE, ((CFA_Partner_Program__c)statementCodesMap.get(statementCodeLabel)).Statement_Code_Multi_Rate_Opt_In__c);
                }

                // if (!statementCodesMap.containsKey(statementCodeLabel)) {
                //     throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
                // }
            }
        }

        return doc.toXmlString().remove(XML_DOCTYPE);
    }
    /**
     * @description This method is used to generate the request body for updating the Credit Total Draw Limit when loan amount or reserved amount gets updated
     * @param requestList 
     * @return  `String`
     */
    public static String generateXMLBodyForLoanAmountUpdate(List<Map<String, Object>> requestList){
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode nls = doc.createRootElement('NLS', null, null);
        
        Dom.XmlNode loan = nls.addChildElement(LOAN, null, null);
        loan.setAttribute(LOAN_NUMBER, String.valueOf(requestList[0].get('loanNumber')));
        loan.setAttribute(UPDATE_FLAG,'1');
        Dom.XmlNode cerditLimit = loan.addChildElement(LOAN_CREDIT_LINE, null, null);
        cerditLimit.setAttribute(NAME, 'Main');
        cerditLimit.setAttribute(UPDATE_FLAG, '1');
        cerditLimit.setAttribute(CREDIT_TOTAL_DRAW_LIMIT, String.valueOf(requestList[0].get('creditTotalDrawLimit')));

        return doc.toXmlString().remove(XML_DOCTYPE);
    }

    /**
     * @description This method is used to generate request body for updating loan amount and maturity date in NLS
     * @param applicationNote 
     * @return  `String`
     */
    public static String generateXMLBodyForModificationRequest(List<Map<String, Object>> applicationNote){
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode nls = doc.createRootElement('NLS', null, null);
        Dom.XmlNode loan = nls.addChildElement(LOAN, null, null);
        loan.setAttribute(LOAN_NUMBER, String.valueOf(applicationNote[0].get('loanNumber')));
        if(applicationNote.size()>0 && applicationNote[0].get('maturityDate')!=null){
            loan.setAttribute(CURR_MATURITY_DATE, String.valueOf(applicationNote[0].get('maturityDate')));
        }
        loan.setAttribute(UPDATE_FLAG,'1');
        Dom.XmlNode cerditLimit = loan.addChildElement(LOAN_CREDIT_LINE, null, null);
        cerditLimit.setAttribute(NAME, 'Main');
        cerditLimit.setAttribute(UPDATE_FLAG, '1');
        if(applicationNote.size()>0 && applicationNote[0].get('loanAmount')!=null){
            cerditLimit.setAttribute(CREDIT_LINE_LIMIT, String.valueOf(applicationNote[0].get('loanAmount')));
        }
        return doc.toXmlString().remove(XML_DOCTYPE);
    }
    
    /**
     * @description This method generate the request body to book the application in NLS for Growmark
     * @param requestMapping
     * @return  `String`
     * @exception 
     */
    public String bookToCoreXMLRequestBodyForGrowmark(Map<String,Object> requestMapping){
        
        List<Map<String, Object>> applicationResponses = (List<Map<String, Object>>)requestMapping.get(KEY_APPLICATION);
        List<Map<String, Object>> dealerAddress = (List<Map<String, Object>>)requestMapping.get(KEY_ADDRESS);
        List<Map<String, Object>> childLoanA = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_A);
        List<Map<String, Object>> childLoanB = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_B);
        List<Map<String, Object>> childLoanC = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_C);
        List<Map<String, Object>> childLoanD = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_D);
        List<Map<String, Object>> childLoanE = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_E);
        List<Map<String, Object>> childLoanF = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_F);
        List<Map<String, Object>> childLoanG = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_G);
        List<Map<String, Object>> childLoanH = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS_H);
        List<Map<String, Object>> myProgramHeader = (List<Map<String, Object>>)requestMapping.get(KEY_MY_PROGRAM);
        List<Map<String, Object>> partnerProgram = (List<Map<String, Object>>)requestMapping.get(KEY_PARTNER_PROGRAM);

        checkForNullFields(new Map<String, Object> {
            KEY_APPLICATION_RESPONSE =>  applicationResponses,
            KEY_DEALER_ADDRESS => dealerAddress,
            KEY_MY_PROGRAM_HEADER => myProgramHeader}
        );

        DOM.Document doc = new DOM.Document();
        dom.XmlNode nls = doc.createRootElement('NLS',null,null);

        bookToCoreParentLoanXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, myProgramHeader, nls);

        if(childLoanA != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanA});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanA, nls);
        }
        if(childLoanB != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanB});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanB, nls);
        }
        if(childLoanC != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanC});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanC, nls);
        }
        if(childLoanD != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanD});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanD, nls);
        }
        if(childLoanE != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanE});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanE, nls);
        }
        if(childLoanF != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanF});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanF, nls);
        }
        if(childLoanG != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanG});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanG, nls);
        }
        if(childLoanH != null){
            checkForNullFields(new Map<String, Object> {KEY_PRICING_DETAILS => childLoanH});
            bookToCoreChildLoansXMLRequestBodyForGrowmark(applicationResponses, dealerAddress, childLoanH, nls);
        }

       
        
        requestBody = doc.toXmlString().remove(XML_DOCTYPE);         
        return requestBody;
    }

    /**
    * @description Growmark Book To Core XML Generation for Parent Loan
    * @author Kabir Pramanik | 12-08-2024 
    * @param applicationResponses 
    * @param dealerAddress 
    * @param myProgramHeader 
    * @param nls 
    **/
    public void bookToCoreParentLoanXMLRequestBodyForGrowmark(
                    List<Map<String, Object>> applicationResponses, 
                    List<Map<String, Object>> dealerAddress, 
                    List<Map<String, Object>> myProgramHeader, 
                    dom.XmlNode nls){
        
        String taxIdNo;
        String shortName;
        String accountName;                
        DateTime effectiveDate = Date.today();
        String statementCodeLabel;
        String lastDateOfMonth = ((DateTime) System.today().addMonths(1).toStartofMonth().addDays(-1)).formatGMT('MM/dd/yyyy');
        String maturityDate = ((Datetime)applicationResponses[0].get('MaturityDate')).formatGMT('MM/dd/yyyy');
        if (applicationResponses[0].get('StatementCode') == null) {
            throw new CustomException(CustomMessageConstants.STATEMENT_CODE_ERROR);
        }
        if(String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.INDIVIDUAL
                && String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.SOLE_PROP_ENTITY){
            if (String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.INDIVIDUAL_ENTITY) {
                // dba
                taxIdNo = '';
            } else {
                // business
                taxIdNo = String.valueOf(applicationResponses[0].get('TaxId'));
                if(taxIdNo.length()==9){
                    taxIdNo = taxIdNo.substring(0,2) + '-' + taxIdNo.substring(2);
                }
                else{
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
                } 
            }
            shortName = String.valueOf(applicationResponses[0].get('AccountName'));
        }
        else{
            // individual
            taxIdNo = String.valueOf(applicationResponses[0].get('SSN'));
            if(taxIdNo.length()==9){
                taxIdNo = taxIdNo.substring(0,3) + '-' + taxIdNo.substring(3, 5) + '-' + taxIdNo.substring(5);
            }
            else{
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            shortName = String.valueOf(applicationResponses[0].get('LastName')) + ', '+ String.valueOf(applicationResponses[0].get('FirstName'));
        }
        statementCodeLabel = String.valueOf(applicationResponses[0].get('StatementCode'));
        //assigning My Program name to 'AccountName' according to requirement
        accountName = String.valueOf(myProgramHeader[0].get('Name'));

        dom.XmlNode header = nls.addChildElement('LOAN',null,null);
        header.setAttribute('LoanTemplateName','COMMITMENT-OTHER');
        header.setAttribute('LoanStatusCode','ACTIVE');
        header.setAttribute('CIFNumber',String.valueOf(applicationResponses[0].get('GrowerCIF')));
        header.setAttribute('LoanNumber',String.valueOf(applicationResponses[0].get('LoanNumber')));
        //Map for entity
        header.setAttribute('Entity',entityMap.get(String.valueOf(applicationResponses[0].get('Entity'))));
        header.setAttribute('TaxIDNumber',taxIdNo);
        header.setAttribute('ShortName',shortName);
        header.setAttribute('AccountName', accountName);
        header.setAttribute('LoanClass1Code','815-SIM');
        header.setAttribute('LoanClass2Code','NONE');
        header.setAttribute('OfficerNumber',String.valueOf(dealerAddress[0].get('DealerProdAgOfficer')));
        header.setAttribute('CollectionOfficerNumber',String.valueOf(dealerAddress[0].get('DealerPortfolioManager')));
        header.setAttribute('RiskRatingNo','14');
        header.setAttribute('OriginationDate',effectiveDate.formatGMT('MM/dd/yyyy'));
        header.setAttribute('MaturityDate',maturityDate);
        header.setAttribute('Statement1Code', statementCodeLabel);
        header.setAttribute('NextStatement1Date', lastDateOfMonth);

        dom.XmlNode loanDetail1 = header.addChildElement('LOANDETAIL1',null,null);
        loanDetail1.setAttribute('UserDefined1',String.valueOf(applicationResponses[0].get('CropYear')));
        loanDetail1.setAttribute('UserDefined2',String.valueOf(applicationResponses[0].get('Guarantee')).replace('.00', '%'));
        loanDetail1.setAttribute('UserDefined3',String.valueOf(applicationResponses[0].get('CreditRating')).toUpperCase());
        loanDetail1.setAttribute('UserDefined4', 'NONE');
        loanDetail1.setAttribute('UserDefined5',String.valueOf(applicationResponses[0].get('DealerCIF')));
        loanDetail1.setAttribute('UserDefined6',String.valueOf(dealerAddress[0].get('DealerCity')));
        loanDetail1.setAttribute('UserDefined7',String.valueOf(dealerAddress[0].get('DealerState')));
        loanDetail1.setAttribute('UserDefined9',String.valueOf(applicationResponses[0].get('Name')));
        loanDetail1.setAttribute('UserDefined11','GROWMARK');
        loanDetail1.setAttribute('UserDefined35',String.valueOf(Integer.valueOf(applicationResponses[0].get('LoanAmount'))));
        if(String.valueOf(applicationResponses[0].get('SigningMethod')).equalsIgnoreCase('Paper - Scanned')){
            loanDetail1.setAttribute('UserDefined38','PAPER');
        }
        else{
            loanDetail1.setAttribute('UserDefined38','E-DOC');
        }

        dom.XmlNode loanCreditLine = header.addChildElement('LOANCREDITLINE',null,null);
        loanCreditLine.setAttribute('Name','Main');
        loanCreditLine.setAttribute('CreditLineLimit',String.valueOf(applicationResponses[0].get('LoanAmount')));
        loanCreditLine.setAttribute('CreditTotalDrawLimit',String.valueOf(applicationResponses[0].get('CreditTotalDrawLimit')));
        loanCreditLine.setAttribute('OverdrawThresholdAmount','');

        dom.XmlNode loantoCifRelationship = header.addChildElement('LOANTOCIFRELATIONSHIP',null,null);
        loantoCifRelationship.setAttribute('RelatedCIFNumber',String.valueOf(applicationResponses[0].get('DealerCIF')));
        loantoCifRelationship.setAttribute('RelationshipCode','CO-OP');
    }
    /**
     * @description Growmark Book To Core XML Generation for child Loan
     * @param applicationResponses 
     * @param dealerAddress 
     * @param childLoanB 
     * @param nls 
     * @exception 
     */
    public void bookToCoreChildLoansXMLRequestBodyForGrowmark(
                    List<Map<String, Object>> applicationResponses,
                    List<Map<String, Object>> dealerAddress, 
                    List<Map<String, Object>> childLoanB,
                    dom.XmlNode nls){

        String maturityDate = ((Datetime)applicationResponses[0].get('MaturityDate')).formatGMT('MM/dd/yyyy');
        Boolean hasBillingDate = childLoanB[0].get('hasBillingDate')!=null? Boolean.valueOf(childLoanB[0].get('hasBillingDate')): false;
        String billingDate = hasBillingDate?((Datetime)childLoanB[0].get('billingDate')).formatGMT('MM/dd/yyyy'):maturityDate;
        String setLoanTemplate = hasBillingDate?'INPUTFLEX-OTHER1':'INPUTFLEX-OTHER';
        DateTime effectiveDate = Date.today();
        String taxIdNo;
        Boolean isVariable;
        String shortName = '';

        dom.XmlNode loanChildHeaderB = nls.addChildElement('LOAN',null,null);
        loanChildHeaderB.setAttribute('LoanTemplateName',setLoanTemplate);
        loanChildHeaderB.setAttribute('LoanStatusCode','ACTIVE');
        loanChildHeaderB.setAttribute('CIFNumber',String.valueOf(applicationResponses[0].get('GrowerCIF')));
        loanChildHeaderB.setAttribute('MasterNoteLoanNumber',String.valueOf(applicationResponses[0].get('LoanNumber')));
        loanChildHeaderB.setAttribute('LoanNumber',String.valueOf(childLoanB[0].get('LoanNumber')));
        //Add entity Check
        loanChildHeaderB.setAttribute('Entity',entityMap.get(String.valueOf(applicationResponses[0].get('Entity'))));
        //modularise TIN/SSN
        if(String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.INDIVIDUAL
                        && String.valueOf(applicationResponses[0].get('Entity')) != PortalConstants.SOLE_PROP_ENTITY){
            if (String.valueOf(applicationResponses[0].get('Entity')) == PortalConstants.INDIVIDUAL_ENTITY) {
                // dba 
                taxIdNo = '';
            } else {
                // business
                taxIdNo = String.valueOf(applicationResponses[0].get('TaxId'));
                if(taxIdNo.length()==9){
                    taxIdNo = taxIdNo.substring(0,2) + '-' + taxIdNo.substring(2);
                }
                else{
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
                }  
            }
            shortName = String.valueOf(applicationResponses[0].get('AccountName'));
        }
        else{
            // individual
            taxIdNo = String.valueOf(applicationResponses[0].get('SSN'));
            if(taxIdNo.length()==9){
                taxIdNo = taxIdNo.substring(0,3) + '-' + taxIdNo.substring(3, 5) + '-' + taxIdNo.substring(5);
            }
            else{
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            shortName = String.valueOf(applicationResponses[0].get('LastName')) + ', '+ String.valueOf(applicationResponses[0].get('FirstName'));
        }
        loanChildHeaderB.setAttribute('TaxIDNumber',taxIdNo);
        loanChildHeaderB.setAttribute('ShortName',shortName);
        loanChildHeaderB.setAttribute('AccountName',String.valueOf(childLoanB[0].get('Description')));
        loanChildHeaderB.setAttribute('LoanClass1Code','815-SIM');
        if((Decimal)childLoanB[0].get('Subsidy') > 0){
            loanChildHeaderB.setAttribute('LoanClass2Code','SUBSIDY'); 
        }
        else if((Decimal)childLoanB[0].get('Premium') > 0){
            loanChildHeaderB.setAttribute('LoanClass2Code','PREMIUM'); 
        }
        else{
            loanChildHeaderB.setAttribute('LoanClass2Code','NONE');
        }
        loanChildHeaderB.setAttribute('OfficerNumber',String.valueOf(dealerAddress[0].get('DealerProdAgOfficer')));
        loanChildHeaderB.setAttribute('CollectionOfficerNumber',String.valueOf(dealerAddress[0].get('DealerPortfolioManager')));
        loanChildHeaderB.setAttribute('RiskRatingNo','14');
        loanChildHeaderB.setAttribute('OriginationDate',effectiveDate.formatGMT('MM/dd/yyyy'));
        loanChildHeaderB.setAttribute('FirstPrincipalPaymentDate',billingDate);
        loanChildHeaderB.setAttribute('FirstInterestPaymentDate',billingDate);
        loanChildHeaderB.setAttribute('MaturityDate',maturityDate);

        dom.XmlNode childLoanDetail1B = loanChildHeaderB.addChildElement('LOANDETAIL1',null,null);
        childLoanDetail1B.setAttribute('UserDefined1',String.valueOf(applicationResponses[0].get('CropYear')));
        childLoanDetail1B.setAttribute('UserDefined2',String.valueOf(applicationResponses[0].get('Guarantee')).replace('.00', '%'));
        childLoanDetail1B.setAttribute('UserDefined3',String.valueOf(applicationResponses[0].get('CreditRating')).toUpperCase());
        childLoanDetail1B.setAttribute('UserDefined5',String.valueOf(applicationResponses[0].get('DealerCIF')));
        childLoanDetail1B.setAttribute('UserDefined6',String.valueOf(dealerAddress[0].get('DealerCity')));
        childLoanDetail1B.setAttribute('UserDefined7',String.valueOf(dealerAddress[0].get('DealerState')));
        childLoanDetail1B.setAttribute('UserDefined9',String.valueOf(applicationResponses[0].get('Name')));
        childLoanDetail1B.setAttribute('UserDefined11','GROWMARK');
        childLoanDetail1B.setAttribute('UserDefined35',String.valueOf(Integer.valueOf(applicationResponses[0].get('LoanAmount'))));
        if(String.valueOf(applicationResponses[0].get('SigningMethod')).equalsIgnoreCase('Paper - Scanned')){
            childLoanDetail1B.setAttribute('UserDefined38','PAPER');
        }
        else{
            childLoanDetail1B.setAttribute('UserDefined38','E-DOC');
        }

        dom.XmlNode childLoanCreditLineB = loanChildHeaderB.addChildElement('LOANCREDITLINE',null,null);
        childLoanCreditLineB.setAttribute('Name','Main');
        childLoanCreditLineB.setAttribute('CreditLineLimit','0');
        childLoanCreditLineB.setAttribute('CreditTotalDrawLimit','0');
        childLoanCreditLineB.setAttribute('OverdrawThresholdAmount','');

        //LOANPARTICIPANT element for CFA participation
        dom.XmlNode childLoanParticipantCfaB = loanChildHeaderB.addChildElement('LOANPARTICIPANT',null,null);
        childLoanParticipantCfaB.setAttribute('ParticipantNumber','PRIMARY');
        childLoanParticipantCfaB.setAttribute('ParticipantName','CFA');
        childLoanParticipantCfaB.setAttribute('LoanGroupName','INPUT-OTHER');

        dom.XmlNode childLoanSubsidyPremium = childLoanParticipantCfaB.addChildElement('PARTICIPANTRULE',null,null);
        childLoanSubsidyPremium.setAttribute('RuleName','InterestPayment%');
        childLoanSubsidyPremium.setAttribute('RuleValue','100.00000');

        //LOANPARTICIPANT element for Dealer participation
        dom.XmlNode childLoanParticipantDealerB = loanChildHeaderB.addChildElement('LOANPARTICIPANT',null,null);
        childLoanParticipantDealerB.setAttribute('ParticipantNumber','8'+ String.valueOf(childLoanB[0].get('LoanNumber'))); // 8 + loan number
        childLoanParticipantDealerB.setAttribute('ParticipantName',String.valueOf(dealerAddress[0].get('DealerCity')) +', '+ String.valueOf(dealerAddress[0].get('DealerState')));// city, state 
        String interestTypeValue;
        // if((Decimal)childLoanB[0].get('Subsidy') == 0){ 
        //     childLoanParticipantDealerB.setAttribute('LoanGroupName','PREMIUM');
        // }
        // else if((Decimal)childLoanB[0].get('Premium') == 0){
        //     childLoanParticipantDealerB.setAttribute('LoanGroupName','SUBSIDY');
        // }
        if(Decimal.ValueOf(String.valueOf(childLoanB[0].get('fsIndexRate'))) < Decimal.ValueOf(String.valueOf(childLoanB[0].get('InterestRate')))){
            interestTypeValue = '4';
            childLoanParticipantDealerB.setAttribute('LoanGroupName','PREMIUM');
        }
        else {
            interestTypeValue = '5';
            childLoanParticipantDealerB.setAttribute('LoanGroupName','SUBSIDY');
        }

        dom.XmlNode childLoanParticipantInterestRateRecordDealerB1 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordDealerB1.setAttribute('InterestRate','0.00');
        Integer totalDays = 0;
        String cfaBaseRateAdjuster = '';
        String growerBaseRateAdjuster = '';
        for(Map<String,Object> childLoan : childLoanB){
            if(System.today().daysBetween(Date.ValueOf(childLoan.get('EndDate'))) > 0){
                if((Decimal)childLoan.get('Subsidy') == 0){
                    interestTypeValue = '4';
                }
                else if((Decimal)childLoan.get('Premium') == 0){
                    interestTypeValue = '5';
                }
                isVariable = String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable');
                
                dom.XmlNode childLoanInterestRateRecord1 = loanChildHeaderB.addChildElement('LOANINTERESTRATERECORD',null,null);
                childLoanInterestRateRecord1.setAttribute('InterestType','0');
                childLoanInterestRateRecord1.setAttribute('StepType','1');
                if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                    childLoanInterestRateRecord1.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                }
                else{
                    childLoanInterestRateRecord1.setAttribute('StepDaysFrom','1');
                }
                /*   if(Date.ValueOf(childLoan.get('EndDate'))==(Date)applicationResponses[0].get('MaturityDate')){
                    childLoanInterestRateRecord1.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 5));
                }
                else{*/
                    childLoanInterestRateRecord1.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 1));

                //  } 
                childLoanInterestRateRecord1.setAttribute('CapRate','100');
                if(String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable')){
                    growerBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('InterestRate')))-Decimal.ValueOf(String.valueOf(childLoan.get('fsIndexRate'))));
                    childLoanInterestRateRecord1.setAttribute('BaseRateAdjuster',growerBaseRateAdjuster);
                    childLoanInterestRateRecord1.setAttribute('BaseRateName','6-FS INDEX');
                    childLoanInterestRateRecord1.setAttribute('InitialRateChangeType','1');
                    childLoanInterestRateRecord1.setAttribute('InitialRateChangeNumberofPeriods','1');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangeType','5');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangeNumberofPeriods','1');
                    childLoanInterestRateRecord1.setAttribute('InitialRateChangePeriod','DA');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangeType','5');
                    childLoanInterestRateRecord1.setAttribute('SubsequentRateChangePeriod','DA');
                }
                else{
                    growerBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('InterestRate'))));
                    childLoanInterestRateRecord1.setAttribute('InterestRate',growerBaseRateAdjuster);
                }

                dom.XmlNode childLoanParticipantInterestRateRecordCfa = childLoanParticipantCfaB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
                childLoanParticipantInterestRateRecordCfa.setAttribute('InterestType','0');
                childLoanParticipantInterestRateRecordCfa.setAttribute('StepType','1');
                if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                    childLoanParticipantInterestRateRecordCfa.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')))+1));
                }
                else{
                    childLoanParticipantInterestRateRecordCfa.setAttribute('StepDaysFrom','1');
                }
                childLoanParticipantInterestRateRecordCfa.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate')))+1));
                cfaBaseRateAdjuster = String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('CfaParticipation'))) * -1);
                childLoanParticipantInterestRateRecordCfa.setAttribute('BaseRateAdjuster',cfaBaseRateAdjuster);
                childLoanParticipantInterestRateRecordCfa.setAttribute('InitialRateChangePeriod','DA');
                childLoanParticipantInterestRateRecordCfa.setAttribute('SubsequentRateChangePeriod','DA');
                childLoanParticipantInterestRateRecordCfa.setAttribute('CapRate','100');
                childLoanParticipantInterestRateRecordCfa.setAttribute('BaseRateName','6-FS INDEX');
                childLoanParticipantInterestRateRecordCfa.setAttribute('InitialRateChangeType','1');
                childLoanParticipantInterestRateRecordCfa.setAttribute('InitialRateChangeNumberofPeriods','1');
                childLoanParticipantInterestRateRecordCfa.setAttribute('SubsequentRateChangeType','5');
                childLoanParticipantInterestRateRecordCfa.setAttribute('SubsequentRateChangeNumberofPeriods','1'); 
                if(Date.ValueOf(childLoan.get('EndDate'))==(Date)applicationResponses[0].get('MaturityDate')){        
                    dom.XmlNode childLoanParticipantInterestRateRecordDealer22 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestType',interestTypeValue); //4=Premium, 5=subsidy
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('StepType','1');
                    //childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom', String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                    if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                    }
                    else{
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom','1');
                    }
                    
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 5));
                    childLoanParticipantInterestRateRecordDealer22.setAttribute('CapRate','100');
                    if(String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable')){
                        if(interestTypeValue == '4'){
                            childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))));
                        }
                        else{
                            childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))));
                        }
                    }
                    else{
                        if(interestTypeValue == '4'){
                            childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))-Decimal.ValueOf(String.valueOf(childLoan.get('fsIndexRate')))));
                        }
                        else{
                            childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))-Decimal.ValueOf(String.valueOf(childLoan.get('fsIndexRate')))));
                        }
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('BaseRateName','6-FS INDEX');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('InitialRateChangeType','1');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('InitialRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('SubsequentRateChangeType','5');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('SubsequentRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('InitialRateChangePeriod','DA');
                        childLoanParticipantInterestRateRecordDealer22.setAttribute('SubsequentRateChangePeriod','DA');
                    }
                }
                else{
                    dom.XmlNode childLoanParticipantInterestRateRecordDealer2 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('InterestType',interestTypeValue); //4=Premium, 5=subsidy
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('StepType','1');
                    if(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate')) + 1) > 0){
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('StepDaysFrom',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('StartDate'))) + 1));
                    }
                    else{
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('StepDaysFrom','1');
                    }
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('StepDaysTo',String.valueOf(Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 1));
                    childLoanParticipantInterestRateRecordDealer2.setAttribute('CapRate','100');
                    if(String.valueOf(childLoan.get('InterestType')).equalsIgnoreCase('Variable')){
                        if(interestTypeValue == '4'){
                            childLoanParticipantInterestRateRecordDealer2.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))));
                        }
                        else{
                            childLoanParticipantInterestRateRecordDealer2.setAttribute('InterestRate',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))));
                        }
                    }
                    else{
                        if(interestTypeValue == '4'){
                            childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Premium')))-Decimal.ValueOf(String.valueOf(childLoan.get('fsIndexRate')))));
                        }
                        else{
                            childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateAdjuster',String.valueOf(Decimal.ValueOf(String.valueOf(childLoan.get('Subsidy')))-Decimal.ValueOf(String.valueOf(childLoan.get('fsIndexRate')))));
                        }
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('BaseRateName','6-FS INDEX');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('InitialRateChangeType','1');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('InitialRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('SubsequentRateChangeType','5');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('SubsequentRateChangeNumberofPeriods','1');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('InitialRateChangePeriod','DA');
                        childLoanParticipantInterestRateRecordDealer2.setAttribute('SubsequentRateChangePeriod','DA');
                    }
                }
                totalDays = Date.ValueOf(System.today()).daysBetween(Date.ValueOf(childLoan.get('EndDate'))) + 1;
            }
        }
           
        dom.XmlNode childLoanInterestRateRecord2 = loanChildHeaderB.addChildElement('LOANINTERESTRATERECORD',null,null);
        childLoanInterestRateRecord2.setAttribute('InterestType','1');
        childLoanInterestRateRecord2.setAttribute('StepType','1');
        childLoanInterestRateRecord2.setAttribute('StepDaysFrom','1');
        childLoanInterestRateRecord2.setAttribute('StepDaysTo','5');
        childLoanInterestRateRecord2.setAttribute('CapRate','100');
        if(isVariable){
            childLoanInterestRateRecord2.setAttribute('BaseRateAdjuster',growerBaseRateAdjuster);
            childLoanInterestRateRecord2.setAttribute('BaseRateName','6-FS INDEX');
            childLoanInterestRateRecord2.setAttribute('InitialRateChangeType','1');
            childLoanInterestRateRecord2.setAttribute('InitialRateChangeNumberofPeriods','1');
            childLoanInterestRateRecord2.setAttribute('SubsequentRateChangeType','5');
            childLoanInterestRateRecord2.setAttribute('SubsequentRateChangeNumberofPeriods','1');
            childLoanInterestRateRecord2.setAttribute('InitialRateChangePeriod','DA');
            childLoanInterestRateRecord2.setAttribute('SubsequentRateChangePeriod','DA');
        }
        else{
            childLoanInterestRateRecord2.setAttribute('InterestRate',growerBaseRateAdjuster);
        }

        dom.XmlNode childLoanInterestRateRecord3 = loanChildHeaderB.addChildElement('LOANINTERESTRATERECORD',null,null);
        childLoanInterestRateRecord3.setAttribute('InterestType','1');
        childLoanInterestRateRecord3.setAttribute('StepType','1');
        childLoanInterestRateRecord3.setAttribute('StepDaysFrom','6');
        childLoanInterestRateRecord3.setAttribute('StepDaysTo','6');
        childLoanInterestRateRecord3.setAttribute('BaseRateName','6-FS INDEX');
        childLoanInterestRateRecord3.setAttribute('BaseRateAdjuster','5.5');
        childLoanInterestRateRecord3.setAttribute('InitialRateChangeType','1');
        childLoanInterestRateRecord3.setAttribute('InitialRateChangePeriod','DA');
        childLoanInterestRateRecord3.setAttribute('InitialRateChangeNumberofPeriods','1');
        childLoanInterestRateRecord3.setAttribute('SubsequentRateChangeType','5');
        childLoanInterestRateRecord3.setAttribute('SubsequentRateChangePeriod','DA');
        childLoanInterestRateRecord3.setAttribute('SubsequentRateChangeNumberofPeriods','1');
        childLoanInterestRateRecord3.setAttribute('CapRate','100');

        dom.XmlNode childLoanParticipantInterestRateRecordCfa11 = childLoanParticipantCfaB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InterestType','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('StepType','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('StepDaysFrom','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('StepDaysTo','5');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('BaseRateAdjuster', cfaBaseRateAdjuster);
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InitialRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('SubsequentRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('CapRate','100');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('BaseRateName','6-FS INDEX');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InitialRateChangeType','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('InitialRateChangeNumberofPeriods','1');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('SubsequentRateChangeType','5');
        childLoanParticipantInterestRateRecordCfa11.setAttribute('SubsequentRateChangeNumberofPeriods','1');

        dom.XmlNode childLoanParticipantInterestRateRecordCfa12 = childLoanParticipantCfaB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InterestType','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('StepType','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('StepDaysFrom','6');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('StepDaysTo','6');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('BaseRateAdjuster','5.5');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InitialRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('SubsequentRateChangePeriod','DA');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('CapRate','100');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('BaseRateName','6-FS INDEX');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InitialRateChangeType','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('InitialRateChangeNumberofPeriods','1');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('SubsequentRateChangeType','5');
        childLoanParticipantInterestRateRecordCfa12.setAttribute('SubsequentRateChangeNumberofPeriods','1');

        dom.XmlNode childLoanParticipantInterestRateRecordDealer22 = childLoanParticipantDealerB.addChildElement('PARTICIPANTINTERESTRATERECORD',null,null);
        childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestType',interestTypeValue); //4=Premium, 5=subsidy
        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepType','1');
        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysFrom', String.valueOf(totalDays + 5));
        childLoanParticipantInterestRateRecordDealer22.setAttribute('StepDaysTo', String.valueOf(totalDays + 5));
        childLoanParticipantInterestRateRecordDealer22.setAttribute('InterestRate','0.00');
        childLoanParticipantInterestRateRecordDealer22.setAttribute('CapRate','100');

        dom.XmlNode childLoantoCifRelationshipB = loanChildHeaderB.addChildElement('LOANTOCIFRELATIONSHIP',null,null);
        childLoantoCifRelationshipB.setAttribute('RelatedCIFNumber',String.valueOf(applicationResponses[0].get('DealerCIF')));
        childLoantoCifRelationshipB.setAttribute('RelationshipCode','CO-OP');
    }

    /**
    * @description This method is used to generate the request body for updating the credit total draw limit into NLS when product return is done
    * @param requestList 
    * @return  `String`
    */
   public static String generateXMLBodyForCreditDrawLimitUpdate(List<Map<String, Object>> requestList){
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode nls = doc.createRootElement('NLS', null, null);
        
        Dom.XmlNode transactions = nls.addChildElement('TRANSACTIONS', null, null);
        transactions.setAttribute('CommitEachTransaction', '1');
        transactions.setAttribute('BatchReference','0');
        Dom.XmlNode transactionCode = transactions.addChildElement('TRANSACTIONCODE', null, null);
        transactionCode.setAttribute('EffectiveDate', Date.today().format());
        transactionCode.setAttribute('LoanNumber',  String.valueOf(requestList[0].get('parentLoanNumber')));
        transactionCode.setAttribute('Amount', String.valueOf(requestList[0].get('Amount')));
        transactionCode.setAttribute('TransactionCode', '108');

        return doc.toXmlString().remove(XML_DOCTYPE);
    }
}