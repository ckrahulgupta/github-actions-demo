/**********************************************************************************************************************
 * @description       : This portal API class helps in fetching all the loans Transaction details for a particular loan ID.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : Sk Minsar
**********************************************************************************************************************/

global without sharing class PortalNLSLoanTransactionsAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static final String NLS_LOAN_TRANSACTIONS_API = 'PortalNLSLoanTransactionsAPI';
    public static final String KEY_PRICING_ID = 'loanNumber';
    public static final String KEY_LOAN_ID = 'loanId';
    public static final String KEY_TRANSACTION_CODE = 'Transaction_Code';
    public static final String KEY_TRANSREF_NUM = 'Transrefno';
    public static final String KEY_REVERSAL_TRANSREF = 'Reversal_Transrefno';
    public static final String KEY_LOAN_GROUP = 'Loan_Group_No';
    public static final String KEY_LOAN_PARTICIPANTS = 'Participant_Detail_Flag';
    public static final String KEY_TRANSACTION_DATE = 'Transaction_Date';
    public static final String DATE_PATTERN_REGEX = '^([\\d]{4})-([\\d]{2})-([\\d]{2})';

    
    /**
    * @description : Method called from portal tp fetch all loan transaction details for a partivulat loan Id
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> request) {
        
        string loanId;
        string loanNumber;
        Integer transactionCode;
        Integer reversalTransref;
        Integer loanGroupNo;
        Integer transactionRefno;
        Boolean participantDetailFlag;
        String transactionCodeString = ConstantValues.TRANSACTION_CODES;
        String transactionLoanGroup = ConstantValues.TRANSACTIONS_LOAN_GROUP;
        List<String> transactionCodeList = transactionCodeString.split(',');
        List<String> transactionLoanGroupList = transactionLoanGroup.split(',');
        Set<Integer> mySet = new Set<Integer>();
        Set<Integer> transactionLoanSet = new Set<Integer>();

        for(String eachCode : transactionCodeList){
            mySet.add(Integer.valueOf(eachCode));
        }

        for(String each : transactionLoanGroupList){
            transactionLoanSet.add(Integer.valueOf(each));
        }

        clcommon.Response response = new clcommon.Response();
        List<Object> parseResponse = new List<Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            List<User> currentUserList = [SELECT id, 
                                            accountId 
                                            FROM User 
                                            WHERE id =:UserInfo.getUserId()];
            if(currentUserList.size() == 0){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }                                
            //Check required params.
            if (request.containsKey(KEY_PRICING_ID) && request.get(KEY_PRICING_ID) != null){
                // throw new CustomException(ConstantValues.PARAMETER_MISSING);
                loanNumber = String.valueOf(request.get(KEY_PRICING_ID));

                List<genesis__Application_Pricing_Detail__c> objPricingLoanIdList = [SELECT Loan_Id__c,
                                                                                                            Loan_Number__c 
                                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                                        WHERE Id = :loanNumber LIMIT 1];

                if (objPricingLoanIdList.size() != 1 
                        || objPricingLoanIdList[0].Loan_Id__c == null) {
                    throw new CustomException(PortalConstants.INVALID_LOAN_NUMBER_ERROR);
                }
                
                if(currentUserList.size() > 0){
                    parseResponse = NLSCallout.nlsGetLoanTransactionsCalloutMethod(currentUserList[0].accountId, 
                                                                                    objPricingLoanIdList[0].Loan_Id__c);
                }
            } else if (request.get(KEY_LOAN_ID) != null) {
                 
                loanId = (String) request.get(KEY_LOAN_ID);
                parseResponse = NLSCallout.nlsGetLoanTransactionsCalloutMethod(currentUserList[0].accountId, loanId);
                
            } else {
                throw new CustomException(ConstantValues.PARAMETER_MISSING);
            }
            
            if(parseResponse == null){
                throw new CustomException(ConstantValues.INTEGRATION_FAILED);
            }
            Map<String,Object> transactionData;

            String datetimeString;
            String dateString;

            Pattern datePattern = Pattern.compile(DATE_PATTERN_REGEX);
            Matcher dateMatcher;
            
            for(Object data: parseResponse) {
                transactionCode = (Integer)((Map<String,Object>)Data).get(KEY_TRANSACTION_CODE);
                transactionRefno = (Integer)((Map<String,Object>)Data).get(KEY_TRANSREF_NUM);
                reversalTransref = (Integer)((Map<String,Object>)Data).get(KEY_REVERSAL_TRANSREF);
                loanGroupNo = (Integer)((Map<String,Object>)Data).get(KEY_LOAN_GROUP);
                participantDetailFlag = (Boolean)((Map<String,Object>)Data).get(KEY_LOAN_PARTICIPANTS);
                if(math.mod(transactionCode, 2) == 0 && !mySet.contains(transactionCode) && reversalTransref==0 && (participantDetailFlag==false && transactionLoanSet.contains(loanGroupNo))){
                    transactionData = (Map<String,Object>)data;

                    datetimeString = (String) transactionData.get(KEY_TRANSACTION_DATE);

                    dateMatcher = datePattern.matcher(datetimeString); 

                    if (dateMatcher.find()) {
                        dateString = dateMatcher.group(1) + '-' + dateMatcher.group(2) + '-' + dateMatcher.group(3);

                        transactionData.put(KEY_TRANSACTION_DATE, dateString);
                    }

                    responseData.add( new clcommon.PortalCustomRemoteActionRecord((Map<String,Object>)Data));
                }
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.status = clcommon.Constants.SUCCESS; 
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objException, NLS_LOAN_TRANSACTIONS_API);
        }
        return response; 
    }
}