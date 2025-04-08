/**
 * @description       : Purpose of this class is to fetch all the pending task of a dealer
 * @author            : Krishanu Chinya
 * @created date      : 18-07-2023 
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/

global without sharing class PortalFetchPendingTaskAPI implements clcommon.PortalCustomRemoteAPI1{
    
    private final String CLASSNAME = PortalFetchPendingTaskAPI.class.getName();

    //CONSTANTS
    public static final String KEY_NO_COMMENTS_TO_DISPLAY = 'No comments to display';
    public static final String KEY_AOI_APP_ID = 'AOI_appId';
    public static final String KEY_AOI_LABEL = 'AOI_label';
    public static final String KEY_AOI_ACTIVE_TASK = 'AOI_task_active';
    public static final String KEY_AOI_COMMENT = 'AOI_comment';
    public static final String KEY_AOI_GROWER = 'AOI_grower';
    public static final String KEY_AOI_CL = 'AOI_cl';
    public static final String KEY_AOI_SALES_REP = 'AOI_sales_rep';
    public static final String KEY_AOI_IRC = 'AOI_irc';
    public static final String KEY_AOI_UNIQUE_IDENTIFIER = 'AOI_unique_identifier';
    public static final String KEY_AOI_CROP_YEAR = 'AOI_crop_year';

    public static final String KEY_COLL_REPORT_APPID = 'coll_rep_appId';
    public static final String KEY_COLL_REPORT_LABEL = 'coll_rep_label';
    public static final String KEY_COLL_REPORT_ACTIVE_TASK = 'coll_rep_task_active';
    public static final String KEY_COLL_REPORT_COMMENT = 'coll_rep_comment';
    public static final String KEY_COLL_REPORT_GROWER = 'coll_rep_grower';
    public static final String KEY_COLL_REPORT_CL = 'coll_rep_cl';
    public static final String KEY_COLL_REPORT_SALES_REP = 'coll_rep_sales_rep';
    public static final String KEY_COLL_REPORT_IRC = 'coll_rep_irc';
    public static final String KEY_COLL_REPORT_UNIQUE_IDENTIFIER = 'coll_rep_unique_identifier';
    public static final String KEY_COLL_REPORT_CROP_YEAR = 'coll_rep_crop_year';

    public static final String KEY_ENTITY_DOC_APPID = 'entity_doc_appId';
    public static final String KEY_ENTITY_DOC_LABEL = 'entity_doc_label';
    public static final String KEY_ENTITY_DOC_ACTIVE_TASK = 'entity_doc_task_active';
    public static final String KEY_ENTITY_DOC_COMMENT = 'entity_doc_comment';
    public static final String KEY_ENTITY_DOC_GROWER = 'entity_doc_grower';
    public static final String KEY_ENTITY_DOC_CL = 'entity_doc_cl';
    public static final String KEY_ENTITY_DOC_SALES_REP = 'entity_doc_sales_rep';
    public static final String KEY_ENTITY_DOC_IRC = 'entity_doc_irc';
    public static final String KEY_ENTITY_DOC_UNIQUE_IDENTIFIER = 'entity_doc_unique_identifier';
    public static final String KEY_ENTITY_DOC_CROP_YEAR = 'entity_doc_crop_year';

    public static final String KEY_CONFIRM_PAYOFF_APPID = 'confirmation_of_payoff_appId';
    public static final String KEY_CONFIRM_PAYOFF_LABEL = 'confirmation_of_payoff_label';
    public static final String KEY_CONFIRM_PAYOFF_ACTIVE_TASK = 'confirmation_of_payoff_active';
    public static final String KEY_CONFIRM_PAYOFF_COMMENT = 'confirmation_of_payoff_comment';
    public static final String KEY_CONFIRM_PAYOFF_GROWER = 'confirmation_of_payoff_grower';
    public static final String KEY_CONFIRM_PAYOFF_CL = 'confirmation_of_payoff_cl';
    public static final String KEY_CONFIRM_PAYOFF_SALES_REP = 'confirmation_of_payoff_sales_rep';
    public static final String KEY_CONFIRM_PAYOFF_IRC = 'confirmation_of_payoff_irc';
    public static final String KEY_CONFIRM_PAYOFF_UNIQUE_IDENTIFIER = 'confirmation_of_payoff_unique_identifier';
    public static final String KEY_CONFIRM_PAYOFF_CROP_YEAR = 'confirmation_of_payoff_crop_year';

    public static final String KEY_LIEN_SEARCH_APPID = 'lien_search_appId';
    public static final String KEY_LIEN_SEARCH_LABEL = 'lien_search_label';
    public static final String KEY_LIEN_SEARCH_ACTIVE_TASK = 'lien_search_active';
    public static final String KEY_LIEN_SEARCH_COMMENT = 'lien_search_comment';
    public static final String KEY_LIEN_SEARCH_GROWER = 'lien_search_grower';
    public static final String KEY_LIEN_SEARCH_CL = 'lien_search_cl';
    public static final String KEY_LIEN_SEARCH_SALES_REP = 'lien_search_sales_rep';
    public static final String KEY_LIEN_SEARCH_IRC = 'lien_search_irc';
    public static final String KEY_LIEN_SEARCH_UNIQUE_IDENTIFIER = 'lien_search_unique_identifier';
    public static final String KEY_LIEN_SEARCH_CROP_YEAR = 'lien_search_crop_year';

    public static final String KEY_LIEN_SUBORDINATION_APPID = 'lien_subordination_appId';
    public static final String KEY_LIEN_SUBORDINATION_LABEL = 'lien_subordination_label';
    public static final String KEY_LIEN_SUBORDINATION_ACTIVE_TASK = 'lien_subordination_active';
    public static final String KEY_LIEN_SUBORDINATION_COMMENT = 'lien_subordination_comment';
    public static final String KEY_LIEN_SUBORDINATION_GROWER = 'lien_subordination_grower';
    public static final String KEY_LIEN_SUBORDINATION_CL = 'lien_subordination_cl';
    public static final String KEY_LIEN_SUBORDINATION_SALES_REP = 'lien_subordination_sales_rep';
    public static final String KEY_LIEN_SUBORDINATION_IRC = 'lien_subordination_irc';
    public static final String KEY_LIEN_SUBORDINATION_UNIQUE_IDENTIFIER = 'lien_subordination_unique_identifier';
    public static final String KEY_LIEN_SUBORDINATION_CROP_YEAR = 'lien_subordination_crop_year';

    public static final String KEY_SEC_NOTICE_APPID = 'sec_notice_appId';
    public static final String KEY_SEC_NOTICE_LABEL = 'sec_notice_label';
    public static final String KEY_SEC_NOTICE_ACTIVE_TASK = 'sec_notice_active';
    public static final String KEY_SEC_NOTICE_COMMENT = 'sec_notice_comment';
    public static final String KEY_SEC_NOTICE_GROWER = 'sec_notice_grower';
    public static final String KEY_SEC_NOTICE_CL = 'sec_notice_cl';
    public static final String KEY_SEC_NOTICE_SALES_REP = 'sec_notice_sales_rep';
    public static final String KEY_SEC_NOTICE_IRC = 'sec_notice_irc';
    public static final String KEY_SEC_NOTICE_UNIQUE_IDENTIFIER = 'sec_notice_unique_identifier';
    public static final String KEY_SEC_NOTICE_CROP_YEAR = 'sec_notice_crop_year';

    public static final String KEY_CNS_APPID = 'CNS_appId';
    public static final String KEY_CNS_LABEL = 'CNS_label';
    public static final String KEY_CNS_ACTIVE_TASK = 'CNS_active';
    public static final String KEY_CNS_COMMENT = 'CNS_comment';
    public static final String KEY_CNS_GROWER = 'CNS_grower';
    public static final String KEY_CNS_CL = 'CNS_cl';
    public static final String KEY_CNS_SALES_REP = 'CNS_sales_rep';
    public static final String KEY_CNS_IRC = 'CNS_irc';
    public static final String KEY_CNS_UNIQUE_IDENTIFIER = 'CNS_unique_identifier';
    public static final String KEY_CNS_CROP_YEAR = 'CNS_crop_year';

    public static final String KEY_CREDIT_AGREEMENT_APPID = 'signed_credit_agreement_appId';
    public static final String KEY_CREDIT_AGREEMENT_LABEL = 'signed_credit_agreement_label';
    public static final String KEY_CREDIT_AGREEMENT_ACTIVE_TASK = 'signed_credit_agreement_active';
    public static final String KEY_CREDIT_AGREEMENT_COMMENT = 'signed_credit_agreement_comment';
    public static final String KEY_CREDIT_AGREEMENT_GROWER = 'signed_credit_agreement_grower';
    public static final String KEY_CREDIT_AGREEMENT_CL = 'signed_credit_agreement_cl';
    public static final String KEY_CREDIT_AGREEMENT_SALES_REP = 'signed_credit_agreement_sales_rep';
    public static final String KEY_CREDIT_AGREEMENT_IRC = 'signed_credit_agreement_irc';
    public static final String KEY_CREDIT_AGREEMENT_UNIQUE_IDENTIFIER= 'signed_credit_agreement_unique_identifier';
    public static final String KEY_CREDIT_AGREEMENT_CROP_YEAR = 'signed_credit_agreement_crop_year';

    public static final String KEY_SPOUSAL_CONSENT_APPID = 'spousal_consent_appId';
    public static final String KEY_SPOUSAL_CONSENT_LABEL = 'spousal_consent_label';
    public static final String KEY_SPOUSAL_CONSENT_ACTIVE_TASK = 'spousal_consent_active';
    public static final String KEY_SPOUSAL_CONSENT_COMMENT = 'spousal_consent_comment';
    public static final String KEY_SPOUSAL_CONSENT_GROWER = 'spousal_consent_grower';
    public static final String KEY_SPOUSAL_CONSENT_CL = 'spousal_consent_cl';
    public static final String KEY_SPOUSAL_CONSENT_SALES_REP = 'spousal_consent_sales_rep';
    public static final String KEY_SPOUSAL_CONSENT_IRC = 'spousal_consent_irc';
    public static final String KEY_SPOUSAL_CONSENT_UNIQUE_IDENTIFIER = 'spousal_consent_unique_identifier';
    public static final String KEY_SPOUSAL_CONSENT_CROP_YEAR = 'spousal_consent_crop_year';

    public static final String KEY_UCC_AMENDMENT_APPID = 'ucc_amendment_appId';
    public static final String KEY_UCC_AMENDMENT_LABEL = 'ucc_amendment_label';
    public static final String KEY_UCC_AMENDMENT_ACTIVE_TASK = 'ucc_amendment_active';
    public static final String KEY_UCC_AMENDMENT_COMMENT = 'ucc_amendment_comment';
    public static final String KEY_UCC_AMENDMENT_GROWER = 'ucc_amendment_grower';
    public static final String KEY_UCC_AMENDMENT_CL = 'ucc_amendment_cl';
    public static final String KEY_UCC_AMENDMENT_SALES_REP = 'ucc_amendment_sales_rep';
    public static final String KEY_UCC_AMENDMENT_IRC = 'ucc_amendment_irc';
    public static final String KEY_UCC_AMENDMENT_UNIQUE_IDENTIFIER = 'ucc_amendment_unique_identifier';
    public static final String KEY_UCC_AMENDMENT_CROP_YEAR = 'ucc_amendment_crop_year';

    public static final String KEY_UCC_FILING_APPID = 'ucc_filing_appId';
    public static final String KEY_UCC_FILING_LABEL = 'ucc_filing_label';
    public static final String KEY_UCC_FILING_ACTIVE_TASK = 'ucc_filing_active';
    public static final String KEY_UCC_FILING_COMMENT = 'ucc_filing_comment';
    public static final String KEY_UCC_FILING_GROWER = 'ucc_filing_grower';
    public static final String KEY_UCC_FILING_CL = 'ucc_filing_cl';
    public static final String KEY_UCC_FILING_SALES_REP = 'ucc_filing_sales_rep';
    public static final String KEY_UCC_FILING_IRC = 'ucc_filing_irc';
    public static final String KEY_UCC_FILING_UNIQUE_IDENTIFIER = 'ucc_filing_unique_identifier';
    public static final String KEY_UCC_FILING_CROP_YEAR = 'ucc_filing_crop_year';

    public static final String KEY_CUST_LOAN_APPROVAL_APPID = 'cust_loan_approval_appId';
    public static final String KEY_CUST_LOAN_APPROVAL_LABEL = 'cust_loan_approval_label';
    public static final String KEY_CUST_LOAN_APPROVAL_ACTIVE_TASK = 'cust_loan_approval_active';
    public static final String KEY_CUST_LOAN_APPROVAL_COMMENT = 'cust_loan_approval_comment';
    public static final String KEY_CUST_LOAN_APPROVAL_GROWER = 'cust_loan_approval_grower';
    public static final String KEY_CUST_LOAN_APPROVAL_CL = 'cust_loan_approval_cl';
    public static final String KEY_CUST_LOAN_APPROVAL_SALES_REP = 'cust_loan_approval_sales_rep';
    public static final String KEY_CUST_LOAN_APPROVAL_IRC = 'cust_loan_approval_irc';
    public static final String KEY_CUST_LOAN_APPROVAL_UNIQUE_IDENTIFIER = 'cust_loan_approval_unique_identifier';
    public static final String KEY_CUST_LOAN_APPROVAL_CROP_YEAR = 'cust_loan_approval_crop_year';

    /**
     * @description : This method is used to check whether a comment is present in a task or not.
     * @param actualComment 
     * @return  `String`
     */
    private static String getComment(String actualComment){
        String comment = KEY_NO_COMMENTS_TO_DISPLAY;
        if(!String.isBlank(actualComment)){
            comment = actualComment;
        }
        return comment;
    }

    /**
     * @description : This method is used to add AOI Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addAOITaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.AOI_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.AOI_TASK);
            resultMap.put(KEY_AOI_APP_ID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_AOI_LABEL, eachTask.Subject);
            resultMap.put(KEY_AOI_ACTIVE_TASK, eachTask.genesis__Application__r.AOI_Task_Pending__c);
            resultMap.put(KEY_AOI_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_AOI_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_AOI_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_AOI_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_AOI_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_AOI_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_AOI_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }
    }

    /**
     * @description : This method is used to add Collateral Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addCollateralReportTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.COLLATERAL_REPORT_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.COLLATERAL_REPORT_TASK);
            resultMap.put(KEY_COLL_REPORT_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_COLL_REPORT_LABEL, eachTask.Subject);
            resultMap.put(KEY_COLL_REPORT_ACTIVE_TASK, eachTask.genesis__Application__r.Collateral_Report_Task_Pending__c);
            resultMap.put(KEY_COLL_REPORT_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_COLL_REPORT_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_COLL_REPORT_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_COLL_REPORT_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_COLL_REPORT_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_COLL_REPORT_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_COLL_REPORT_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c); 
        }
    }
        
    /**
     * @description : This method is used to add Entity Documents Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addEntityDocumentsTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.ENTITY_DOC_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.ENTITY_DOC_TASK);
            resultMap.put(KEY_ENTITY_DOC_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_ENTITY_DOC_LABEL, eachTask.Subject);
            resultMap.put(KEY_ENTITY_DOC_ACTIVE_TASK, eachTask.genesis__Application__r.Entity_Documents_Task_Pending__c);
            resultMap.put(KEY_ENTITY_DOC_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_ENTITY_DOC_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_ENTITY_DOC_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_ENTITY_DOC_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_ENTITY_DOC_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_ENTITY_DOC_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_ENTITY_DOC_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }   
    }

    /**
     * @description : This method is used to add Payoff Confirmation Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addPayoffConfirmationTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.PAYOFF_CONFIRMATION_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.PAYOFF_CONFIRMATION_TASK);
            resultMap.put(KEY_CONFIRM_PAYOFF_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_CONFIRM_PAYOFF_LABEL, eachTask.Subject);
            resultMap.put(KEY_CONFIRM_PAYOFF_ACTIVE_TASK, eachTask.genesis__Application__r.Payoff_Confirmation_Task_Pending__c);
            resultMap.put(KEY_CONFIRM_PAYOFF_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_CONFIRM_PAYOFF_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_CONFIRM_PAYOFF_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_CONFIRM_PAYOFF_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_CONFIRM_PAYOFF_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_CONFIRM_PAYOFF_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_CONFIRM_PAYOFF_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }
    }

    /**
     * @description : This method is used to add Lien Search Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addLienSearchTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.LIEN_SEARCH_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.LIEN_SEARCH_TASK);
            resultMap.put(KEY_LIEN_SEARCH_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_LIEN_SEARCH_LABEL, eachTask.Subject);
            resultMap.put(KEY_LIEN_SEARCH_ACTIVE_TASK, eachTask.genesis__Application__r.Lien_Search_Task_Pending__c);
            resultMap.put(KEY_LIEN_SEARCH_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_LIEN_SEARCH_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_LIEN_SEARCH_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_LIEN_SEARCH_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_LIEN_SEARCH_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_LIEN_SEARCH_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_LIEN_SEARCH_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }    
    }

    /**
     * @description : This method is used to add Lien Subordination Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addLienSubordinationTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.LIEN_SUBORDINATION_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.LIEN_SUBORDINATION_TASK);
            resultMap.put(KEY_LIEN_SUBORDINATION_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_LIEN_SUBORDINATION_LABEL, eachTask.Subject);
            resultMap.put(KEY_LIEN_SUBORDINATION_ACTIVE_TASK, eachTask.genesis__Application__r.Lien_Subordination_Task_Pending__c);
            resultMap.put(KEY_LIEN_SUBORDINATION_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_LIEN_SUBORDINATION_GROWER, eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_LIEN_SUBORDINATION_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_LIEN_SUBORDINATION_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_LIEN_SUBORDINATION_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_LIEN_SUBORDINATION_UNIQUE_IDENTIFIER ,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_LIEN_SUBORDINATION_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }    
    }

    /**
     * @description : This method is used to add Security Notice Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addSecurityNoticeTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.NTB_TASK_CFA_ACTION)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.NTB_TASK_CFA_ACTION);
            resultMap.put(KEY_SEC_NOTICE_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_SEC_NOTICE_LABEL, eachTask.Subject);
            resultMap.put(KEY_SEC_NOTICE_ACTIVE_TASK, eachTask.genesis__Application__r.Security_Notice_Task_Pending__c);
            resultMap.put(KEY_SEC_NOTICE_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_SEC_NOTICE_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_SEC_NOTICE_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_SEC_NOTICE_SALES_REP, eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_SEC_NOTICE_IRC, eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_SEC_NOTICE_UNIQUE_IDENTIFIER, eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_SEC_NOTICE_CROP_YEAR, eachTask.genesis__Application__r.Crop_Year__c);
        }
    }

    /**
     * @description : This method is used to add CNS Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addCNSTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.CNS_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.CNS_TASK);
            resultMap.put(KEY_CNS_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_CNS_LABEL, eachTask.Subject);
            resultMap.put(KEY_CNS_ACTIVE_TASK, eachTask.genesis__Application__r.CNS_Task_Pending__c);
            resultMap.put(KEY_CNS_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_CNS_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultmap.put(KEY_CNS_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_CNS_SALES_REP, eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_CNS_IRC, eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_CNS_UNIQUE_IDENTIFIER, eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_CNS_CROP_YEAR, eachTask.genesis__Application__r.Crop_Year__c);
        }   
    }

    /**
     * @description : This method is used to add Signed Agreement Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addSignedAgreementTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.SIGNED_AGREEMENT_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.SIGNED_AGREEMENT_TASK);
            resultMap.put(KEY_CREDIT_AGREEMENT_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_CREDIT_AGREEMENT_LABEL, eachTask.Subject);
            resultMap.put(KEY_CREDIT_AGREEMENT_ACTIVE_TASK, eachTask.genesis__Application__r.Signed_Agreement_Task_Pending__c);
            resultMap.put(KEY_CREDIT_AGREEMENT_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_CREDIT_AGREEMENT_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_CREDIT_AGREEMENT_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_CREDIT_AGREEMENT_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_CREDIT_AGREEMENT_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_CREDIT_AGREEMENT_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_CREDIT_AGREEMENT_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }   
    }

    /**
     * @description : This method to add Spousal Consent Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addSpousalConsentTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.SPOUSAL_CONSENT_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.SPOUSAL_CONSENT_TASK);
            resultMap.put(KEY_SPOUSAL_CONSENT_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_SPOUSAL_CONSENT_LABEL, eachTask.Subject);
            resultMap.put(KEY_SPOUSAL_CONSENT_ACTIVE_TASK, eachTask.genesis__Application__r.Spousal_Consent_Task_Pending__c);
            resultMap.put(KEY_SPOUSAL_CONSENT_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_SPOUSAL_CONSENT_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_SPOUSAL_CONSENT_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_SPOUSAL_CONSENT_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_SPOUSAL_CONSENT_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_SPOUSAL_CONSENT_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_SPOUSAL_CONSENT_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        } 
    }

    /**
     * @description : This method to add UCC Amendment Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addUCCAmendmentTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.UCC_AMENDMENT_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.UCC_AMENDMENT_TASK);
            resultMap.put(KEY_UCC_AMENDMENT_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_UCC_AMENDMENT_LABEL, eachTask.Subject);
            resultMap.put(KEY_UCC_AMENDMENT_ACTIVE_TASK, eachTask.genesis__Application__r.UCC_Amendment_Task_Pending__c);
            resultMap.put(KEY_UCC_AMENDMENT_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_UCC_AMENDMENT_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_UCC_AMENDMENT_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_UCC_AMENDMENT_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_UCC_AMENDMENT_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_UCC_AMENDMENT_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_UCC_AMENDMENT_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }
    }

    /**
     * @description : This method to add UCC Filing Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addUCCFilingTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.UCC_FILING_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.UCC_FILING_TASK);
            resultMap.put(KEY_UCC_FILING_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_UCC_FILING_LABEL, eachTask.Subject);
            resultMap.put(KEY_UCC_FILING_ACTIVE_TASK, eachTask.genesis__Application__r.UCC_Filing_Task_Pending__c);
            resultMap.put(KEY_UCC_FILING_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_UCC_FILING_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultmap.put(KEY_UCC_FILING_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_UCC_FILING_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_UCC_FILING_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_UCC_FILING_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_UCC_FILING_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }   
    }

    /**
     * @description : This method to add Customized Approval Task related information
     * @param subWiseTaskMap 
     * @param resultMap 
     */
    private static void addCustomizedApprovalTaskDetails(Map<String, Task> subWiseTaskMap ,Map<String, Object> resultMap){
        if(subWiseTaskMap.containsKey(PortalConstants.CUSTOMIZED_LOAN_TASK)){
            Task eachTask = subWiseTaskMap.get(PortalConstants.CUSTOMIZED_LOAN_TASK);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_APPID, eachTask.genesis__Application__r.Name);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_LABEL, eachTask.Subject);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_ACTIVE_TASK, eachTask.genesis__Application__r.Customized_Approval_Task_Pending__c);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_COMMENT, getComment(eachTask.Comments__c));
            resultMap.put(KEY_CUST_LOAN_APPROVAL_GROWER,eachTask.genesis__Application__r.genesis__Account__r.Name);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_CL, eachTask.genesis__Application__r.Certified_Lender__r.Name);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_SALES_REP,eachTask.genesis__Application__r.Sales_Agent__r.Name);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_IRC,eachTask.genesis__Application__r.Internal_Reference_Code__c);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_UNIQUE_IDENTIFIER,eachTask.genesis__Application__r.Unique_Identifier__c);
            resultMap.put(KEY_CUST_LOAN_APPROVAL_CROP_YEAR,eachTask.genesis__Application__r.Crop_Year__c);
        }     
    }

    /**
     * @description : This method is used to generate the result map
     * @param subWiseTaskList 
     * @param resultMap 
     */
    private static void generateResultMap(List<Map<String, Task>> subWiseTaskList,Map<String, Object> resultMap){
        for(Integer iterator=0; iterator<subWiseTaskList.size();iterator++){
            Map<String, Task> subWiseTaskMap = subWiseTaskList[iterator];
            addAOITaskDetails(subWiseTaskMap,resultMap);
            addCollateralReportTaskDetails(subWiseTaskMap,resultMap);
            addEntityDocumentsTaskDetails(subWiseTaskMap,resultMap);
            addPayoffConfirmationTaskDetails(subWiseTaskMap,resultMap);
            addLienSearchTaskDetails(subWiseTaskMap,resultMap);
            addLienSubordinationTaskDetails(subWiseTaskMap,resultMap);
            addSecurityNoticeTaskDetails(subWiseTaskMap,resultMap);
            addCNSTaskDetails(subWiseTaskMap,resultMap);
            addSignedAgreementTaskDetails(subWiseTaskMap,resultMap);
            addSpousalConsentTaskDetails(subWiseTaskMap,resultMap);
            addUCCAmendmentTaskDetails(subWiseTaskMap,resultMap);
            addUCCFilingTaskDetails(subWiseTaskMap,resultMap);
            addCustomizedApprovalTaskDetails(subWiseTaskMap,resultMap);
        }
    }

    /**
     * @description : This method to get the Pending Task Report
     * @return  `Object >`
     */
    public static List< Map<String, Object> > getPendingTaskReport()
    {
        List<Task> taskList = new List<Task>();
        List<Map<String, Task>> subWiseTasksList;
        List< Map<String, Object> > resposeDataList = new List< Map<String, Object> >();

        Map<String, List<Map<String, Task>>> taskMap = new  Map<String, List<Map<String, Task>>> ();
        //Map<appId, List<Map<subject, all fields of task object>>>
        List<Map<String, Task>> subWiseTaskList;

        taskList = [SELECT genesis__Application__c,
                        genesis__Application__r.Name,
                        Comments__c,
                        Subject,
                        genesis__Application__r.genesis__Account__r.Name,
                        genesis__Application__r.Internal_Reference_Code__c,
                        genesis__Application__r.Unique_Identifier__c, 
                        genesis__Application__r.Crop_Year__c, 
                        genesis__Application__r.Certified_Lender__r.Name,
                        genesis__Application__r.Sales_Agent__r.Name,
                        genesis__Application__r.Entity_Documents_Task_Pending__c,
                        genesis__Application__r.AOI_Task_Pending__c,
                        genesis__Application__r.Collateral_Report_Task_Pending__c,
                        genesis__Application__r.Payoff_Confirmation_Task_Pending__c,
                        genesis__Application__r.Lien_Search_Task_Pending__c,
                        genesis__Application__r.Lien_Subordination_Task_Pending__c,
                        genesis__Application__r.Security_Notice_Task_Pending__c,
                        genesis__Application__r.CNS_Task_Pending__c,
                        genesis__Application__r.Signed_Agreement_Task_Pending__c,
                        genesis__Application__r.Spousal_Consent_Task_Pending__c,
                        genesis__Application__r.UCC_Amendment_Task_Pending__c,
                        genesis__Application__r.UCC_Filing_Task_Pending__c,
                        genesis__Application__r.Customized_Approval_Task_Pending__c
                        FROM Task
                        WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                        AND (genesis__Application__r.Entity_Documents_Task_Pending__c = true 
                            OR genesis__Application__r.AOI_Task_Pending__c = true
                            OR genesis__Application__r.Collateral_Report_Task_Pending__c = true
                            OR genesis__Application__r.Payoff_Confirmation_Task_Pending__c = true
                            OR genesis__Application__r.Lien_Search_Task_Pending__c = true
                            OR genesis__Application__r.Lien_Subordination_Task_Pending__c = true
                            OR genesis__Application__r.Security_Notice_Task_Pending__c = true
                            OR genesis__Application__r.CNS_Task_Pending__c = true
                            OR genesis__Application__r.Signed_Agreement_Task_Pending__c = true
                            OR genesis__Application__r.Spousal_Consent_Task_Pending__c = true
                            OR genesis__Application__r.UCC_Amendment_Task_Pending__c = true
                            OR genesis__Application__r.UCC_Filing_Task_Pending__c = true
                            OR genesis__Application__r.Customized_Approval_Task_Pending__c = true)
                        AND genesis__Application__r.genesis__Status__c IN ( :PortalConstants.NEW_ENTERED_APPLICATION_STATUS,
                                                                            : PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS,
                                                                            : PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS,
                                                                            : PortalConstants.NEW_SCORECARD_APPLICATION_STATUS,
                                                                            : PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS)];
                                                                            
        for(task eachTask : taskList){
            if(taskMap.containsKey(eachTask.genesis__Application__c)){
                subWiseTasksList = taskMap.get(eachTask.genesis__Application__c);
                Map<String,Task> subWiseTaskMap = new Map<String, Task>();
                subWiseTaskMap.put(eachTask.Subject, eachTask);
                subWiseTasksList.add(subWiseTaskMap);
            }
            else{
                subWiseTasksList = new List<Map<String, Task>>();
                Map<String,Task> subWiseTaskMap = new Map<String, Task>();
                subWiseTaskMap.put(eachTask.Subject, eachTask);
                subWiseTasksList.add(subWiseTaskMap);
            }
            taskMap.put(eachTask.genesis__Application__c, subWiseTasksList);
        }
            
        for(Object key : taskMap.keySet()){
            Map<String, Object> resultMap = new Map<String,Object>();

            subWiseTaskList = taskMap.get(String.valueOf(key));
            generateResultMap(subWiseTaskList, resultMap);
            resposeDataList.add(resultMap);
        }
        return resposeDataList;
    }


    /**
     * @description : This method is used to fetch the pending tasks for a dealer , used for the pending task report.
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     */
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> request)
    {
        clcommon.Response response = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        try {
            List< Map<String, Object> > resposeDataList = getPendingTaskReport();
                
            for(Map<String, Object> result : resposeDataList){
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(result));
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 
        
        } catch (Exception exceptionObj) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, className);
        }
        return response;
    }
}