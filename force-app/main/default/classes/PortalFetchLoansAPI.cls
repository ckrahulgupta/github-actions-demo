/**
 * @description       : Purpose of this class is to fetch all the loans of a particular dealer
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : Rahul Gorai
**/
global without sharing class PortalFetchLoansAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    private static final String CLASS_NAME = 'PortalFetchLoansAPI';
    private static final String KEY_FILTER = 'filter';
    private static final String KEY_ACCOUNT_ID = 'accountId';
    private static final String KEY_ALL = 'ALL';
    private static final String KEY_CURRENT_CROP_YEAR = 'CURRENT CROP YEAR';
    private static final String KEY_PRIOR_CROP_YEAR = 'PRIOR CROP YEAR';
    private static final String KEY_PAST_DUE = 'PAST DUE';

    private static final String KEY_CURRENT_CROP_YEAR_ACTIVE = 'CURRENT CROP YEAR ACTIVE';
    private static final String KEY_PRIOR_CROP_YEAR_ACTIVE = 'PRIOR CROP YEAR ACTIVE';
    private static final String KEY_ONLINE_USERS = 'ONLINE USERS';
    String filter = '';
    String accountId = '';
    Integer year = System.Today().year();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    /**
     * @description 
     * @return  `Id`
     * @exception 
     */
    private static Id getLoggedInUserAccId(){
        List<User>  objCurrentUserList = [SELECT Id, 
                                                AccountId,
                                                Account.ParentId,
                                                Account.RecordType.Name 
                                        FROM User 
                                        WHERE Id =:UserInfo.getUserId() 
                                        LIMIT 1];
        if (objCurrentUserList.isEmpty()) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return objCurrentUserList[0].AccountId;

    }

    /**
     * @description 
     * @return  `Id`
     * @exception 
     */
    private static Id getLoggedInUserDealerId() {
        List<User> objLoggedInUserList =   [SELECT Id,
                                                ContactId,
                                                AccountId,
                                                Account.ParentId
                                            FROM USER
                                            WHERE Id = :UserInfo.getUserId()
                                            LIMIT 1];
        
        if (objLoggedInUserList.isEmpty() || objLoggedInUserList[0].Account.ParentId==null) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return objLoggedInUserList[0].Account.ParentId;
    }

    /**
     * @description - this method is used to get the current crop year at any point of time in a year
     * @return  
     */
    private static Integer getCurrentCropYear(){
        Integer currentMonth = System.today().month();
        Integer cropYear = System.today().year();

        if (currentMonth >= 6) {
            cropYear += 1;
        }
        return cropYear;
    }
    

    /**
    * @description 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return  `clcommon.Response`
    */
    global clcommon.Response invokeAction(String componentStructureName,
                                            String[] disclosureNames,
                                            Map<String, Object> request) {
        List<clcommon__Party__c> loanList = new List<clcommon__Party__c>();

        try {
            filter = String.valueOf(request.get(KEY_FILTER));
            accountId = String.valueOf(request.get(KEY_ACCOUNT_ID));
            loanList = getLoanApplications(filter);
            
            for(clcommon__Party__c loan: loanList) {
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(loan));
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 
        } catch (CustomException customException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASS_NAME);
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 10-01-2025 
    * @param filter 
    * @return clcommon__party__c 
    **/
    private static List<clcommon__party__c> getLoanApplications(String filter){
        List<clcommon__Party__c> loanList = new List<clcommon__Party__c>();
        Integer year;
        if (getFilterAll(filter)) {
            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND (genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS 
                            OR genesis__Application__r.genesis__Status__c =: PortalConstants.CLOSED_APPLICATION_STATUS 
                            OR genesis__Application__r.genesis__Status__c =: PortalConstants.APPROVED_APPLICATION_STATUS)];

        } else if (filter == PortalConstants.ACTIVE_APPLICATION_STATUS) {
            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND (genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS)];

        } else if (filter == PortalConstants.CLOSED_APPLICATION_STATUS) {

            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND genesis__Application__r.genesis__Status__c =: PortalConstants.CLOSED_APPLICATION_STATUS];

        } else if (filter == KEY_CURRENT_CROP_YEAR) {

            year = getCurrentCropYear();

            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND (genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS 
                            OR genesis__Application__r.genesis__Status__c =: PortalConstants.CLOSED_APPLICATION_STATUS 
                            OR genesis__Application__r.genesis__Status__c =: PortalConstants.APPROVED_APPLICATION_STATUS)
                    AND genesis__Application__r.Crop_Year__c =: String.valueOf(year)];

        } else if (filter == KEY_PRIOR_CROP_YEAR) {

            year = getCurrentCropYear()-1;

            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND (genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS 
                            OR genesis__Application__r.genesis__Status__c =: PortalConstants.CLOSED_APPLICATION_STATUS 
                            OR genesis__Application__r.genesis__Status__c =: PortalConstants.APPROVED_APPLICATION_STATUS)
                    AND genesis__Application__r.Crop_Year__c =: String.valueOf(year)];

        } else if (filter == KEY_PAST_DUE) {
            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS
                    AND genesis__Application__r.Past_Due_Amount__c > 0
                    ];
        } else if (filter == PortalConstants.KEY_EVERGREEN_ELIGIBLE) {

            loanList = [SELECT Id,
                            genesis__Application__r.Id,
                            genesis__Application__r.genesis__Credit_Rating__r.Id,
                            genesis__Application__r.genesis__Account__r.Id,
                            genesis__Application__r.Name,
                            genesis__Application__r.genesis__Loan_Number__c,
                            genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            genesis__Application__r.Signing_Method__c,
                            genesis__Application__r.Additional_Information_Needed__c,
                            genesis__Application__r.Credit_Application_And_Agreement_Process__c,
                            genesis__Application__r.My_Program__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.Loan_Id__c,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Growmark_Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Certified_Lenders_Signature__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Is_Evergreen__c,
                            genesis__Application__r.Dealer_Applicant_Relationship__r.Is_Evergreen_Eligible__c,
                            genesis__Application__r.Non_Accrual__c,
                            genesis__Application__r.Past_Due_Amount__c
                    FROM clcommon__Party__c
                    WHERE clcommon__Account__r.Id = :getLoggedInUserAccId()
                    AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                    AND (genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS 
                    OR genesis__Application__r.genesis__Status__c =: PortalConstants.CLOSED_APPLICATION_STATUS)
                    AND genesis__Application__r.Is_Evergreen_Eligible__c =: PortalConstants.TRUE_VALUE];
        } 
        return loanList;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 10-01-2025 
    * @param filter 
    * @return boolean 
    **/
    private static boolean getFilterAll(String filter){
        return (filter == '' || filter == null || filter == KEY_ALL);
    }
}