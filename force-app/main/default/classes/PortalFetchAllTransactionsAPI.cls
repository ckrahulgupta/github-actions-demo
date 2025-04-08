/**
 * @description       : This method fetch all posted, pending transactions
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 04-05-2024
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalFetchAllTransactionsAPI implements clcommon.PortalCustomRemoteAPI1{

    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private Integer transactionCode;
    private Integer reversalTransref;
    private Integer loanGroupNo;
    private Integer transactionRefno;
    private Boolean participantDetailFlag;
    private String transactionCodeString = ConstantValues.TRANSACTION_CODES;
    private String transactionLoanGroup = ConstantValues.TRANSACTIONS_LOAN_GROUP;
    private List<String> transactionCodeList = transactionCodeString.split(',');
    private List<String> transactionLoanGroupList = transactionLoanGroup.split(',');
    private Set<Integer> transactionCodeSet = new Set<Integer>();
    private Set<Integer> transactionLoanSet = new Set<Integer>();
    private List<User> currentUserList = new List<User>();
    
    /**
    * @description - This constractor helps to get loggedIn user and Current user
    * @author Sk Minsar | 03-18-2024 
    **/
    global PortalFetchAllTransactionsAPI(){
        currentUserList = PortalApplicationOriginationHelper.getLoggedInUser();
    }
    /**
    * @description - Returns Transactions
    * @author Sk Minsar | 02-13-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                                String[] disclosureNames,
                                                Map<String, Object> request) {

        for(String eachCode : transactionCodeList){
            transactionCodeSet.add(Integer.valueOf(eachCode));
        }

        for(String each : transactionLoanGroupList){
            transactionLoanSet.add(Integer.valueOf(each));
        }  
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
        String paymentMode;
        String applicationId;
        String transactionsStatus;
        string loanDescription;
        string toDate;
        string fromDate;
        Map<String, String> requestDataMap = new Map<String, String>();

        try{                          

            paymentMode = (String) request.get(PortalConstants.KEY_PAYMENT_MODE);
            applicationId = (String) request.get(PortalConstants.APPLICATION_ID);
            transactionsStatus = (String) request.get(PortalConstants.KEY_TRANSACTIONS_STATUS);
            loanDescription = (String) request.get(PortalConstants.KEY_LOAN_DESCRIPTION);
            fromDate = (String) request.get(PortalConstants.KEY_FROM_DATE);
            toDate = (String) request.get(PortalConstants.KEY_TO_DATE);
            

            LoanServicingHelper.checkEmptyString(applicationId, PortalConstants.REQUIRED_PARAMETERS_MISSING);
            LoanServicingHelper.checkEmptyString(transactionsStatus, PortalConstants.REQUIRED_PARAMETERS_MISSING);
            LoanServicingHelper.checkEmptyString(loanDescription, PortalConstants.REQUIRED_PARAMETERS_MISSING);

            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            requestDataMap.put(PortalConstants.KEY_PAYMENT_MODE, (String) request.get(PortalConstants.KEY_PAYMENT_MODE));
            requestDataMap.put(PortalConstants.APPLICATION_ID, (String) request.get(PortalConstants.APPLICATION_ID));
            requestDataMap.put(PortalConstants.KEY_TRANSACTIONS_STATUS, (String) request.get(PortalConstants.KEY_TRANSACTIONS_STATUS));
            requestDataMap.put(PortalConstants.KEY_LOAN_DESCRIPTION, (String) request.get(PortalConstants.KEY_LOAN_DESCRIPTION));
            requestDataMap.put(PortalConstants.KEY_FROM_DATE, (String) request.get(PortalConstants.KEY_FROM_DATE));
            requestDataMap.put(PortalConstants.KEY_TO_DATE, (String) request.get(PortalConstants.KEY_TO_DATE));
            responseData = getFilteredTransactions(requestDataMap);
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 

        } catch(CustomException customException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASS_NAME);
        } catch(Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description - This method used to filtered transactions
    * @author Sk Minsar | 02-13-2024 
    * @param requestDataMap 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    private List<clcommon.PortalCustomRemoteActionRecord> getFilteredTransactions(Map<String, String> requestDataMap){

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        List<Map<String, Object>>  resultList = getTransactions(requestDataMap);
        for(Map<String, Object> result : resultList){
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(result));
        }
        
        return responseData;  
    }

    
    /**
    * @description - This method is used to query the transactions from field finance
    * @author Sk Minsar | 02-13-2024 
    * @param requestDataMap 
    * @return List<Map<String, Object>> 
    **/
    private List<Map<String, Object>> getTransactions(Map<String, String> requestDataMap){
        String applicationId = requestDataMap.get(PortalConstants.APPLICATION_ID);
        String transactionsStatus = requestDataMap.get(PortalConstants.KEY_TRANSACTIONS_STATUS);
        String loanDescription = requestDataMap.get(PortalConstants.KEY_LOAN_DESCRIPTION);
        String fromDate = requestDataMap.get(PortalConstants.KEY_FROM_DATE);
        String toDate = requestDataMap.get(PortalConstants.KEY_TO_DATE);
        List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
        Map<String, List<Map<String, Object>>> transactionsMap = new Map<String, List<Map<String, Object>>>();
        List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>>();
        List<Map<String, Object>> pendingTransactionsList = new List<Map<String, Object>>();
        List<Map<String, Object>> voidedTransactionsList = new List<Map<String, Object>>();
        List<Map<String, Object>> nlsPostedTransactionList = new List<Map<String, Object>>();
        Map<String,Map<String,Object>> pricingDetailsByLoanIdMap = new Map<String,Map<String,Object>>();
        List<String> pricingDetailList = new List<String>();
        List<String> loanIdList = new List<String>();
        Map<String,List<String>> pricingLoanIdMap = new  Map<String,List<String>>();
        Map<String, String> filterAndSortTrnParamMap = new Map<String, String>();

        filterAndSortTrnParamMap.put(PortalConstants.KEY_FROM_DATE, fromDate);
        filterAndSortTrnParamMap.put(PortalConstants.KEY_TO_DATE, toDate);
        filterAndSortTrnParamMap.put(ConstantValues.DEALER_COOP_TYPE, currentUserList[0].Account.Parent.Coop_Type__c);


        pricingLoanIdMap = getPricingLoanIdMap(applicationId, loanDescription);
        loanIdList = pricingLoanIdMap.get(PortalConstants.LOAN_ID_LIST);
        PortalApplicationOriginationHelper.checkEmptyList(loanIdList, PortalConstants.INVALID_LOAN_NUMBER_ERROR);
        pricingDetailList = pricingLoanIdMap.get(PortalConstants.PRICING_ID_LIST);
        PortalApplicationOriginationHelper.checkEmptyList(pricingDetailList, PortalConstants.INVALID_LOAN_NUMBER_ERROR);

        fundingTransactionList = [SELECT Id,
                                        Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name,
                                        Pricing_Detail__r.Loan_Number__c,
                                        Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                        Pricing_Detail__r.genesis__Interest_Rate__c,
                                        Pricing_Detail__r.Loan_Id__c,
                                        Pricing_Detail__c,
                                        genesis__Amount__c,
                                        genesis__Payment_Mode__r.Name,
                                        genesis__Reference__c,
                                        Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Id,
                                        Pricing_Detail__r.genesis__Application__r.Id,
                                        Draft_Number__c,
                                        Payee__c,
                                        CreatedDate,
                                        Status__c,
                                        Posted_to_NLS__c,
                                        Posted_Date__c,
                                        genesis__Cleared__c 
                                    FROM genesis__Funding_Transaction__c 
                                    WHERE  genesis__Application__r.Id = :applicationId
                                    AND Pricing_Detail__r.genesis__Application__r.Dealer_Name__c =: currentUserList[0].Account.ParentId
                                    AND genesis__Payment_Mode__r.Name In 
                                            (:ConstantValues.ACH, 
                                                :ConstantValues.PRODUCT_RETURN, 
                                                :ConstantValues.DRAFT, 
                                                :ConstantValues.PAYMENT, 
                                                :ConstantValues.MOBILE_DEPOSIT)
                                    AND Pricing_Detail__c IN:pricingDetailList
                                    ORDER BY CreatedDate];

        transactionsMap = getAllTransactionsMap(fundingTransactionList);
        pendingTransactionsList = transactionsMap.get(PortalConstants.PENDING_TRANSACTION_LIST);
        postedTransactionsList = transactionsMap.get(PortalConstants.POSTED_TRANSACTION_LIST);
        voidedTransactionsList = transactionsMap.get(PortalConstants.VOIDED_TRANSACTION_LIST);
        if(transactionsStatus.equals(PortalConstants.STATUS_PENDING)){
            return LoanServicingHelper.filterAndSortTransactions(pendingTransactionsList, filterAndSortTrnParamMap);
        }else if(transactionsStatus.equals(PortalConstants.STATUS_VOIDED)){
            return LoanServicingHelper.filterAndSortTransactions(voidedTransactionsList, filterAndSortTrnParamMap);
        }else if(transactionsStatus.equals(PortalConstants.STATUS_POSTED)){
            pricingDetailsByLoanIdMap = getPricingDetailsByLoanIdMap(loanIdList);
            nlsPostedTransactionList = getPostedTransactionList(loanIdList,pricingDetailsByLoanIdMap, postedTransactionsList);
            return LoanServicingHelper.filterAndSortTransactions(nlsPostedTransactionList, filterAndSortTrnParamMap);
        }
        pricingDetailsByLoanIdMap = getPricingDetailsByLoanIdMap(loanIdList);
        nlsPostedTransactionList = getPostedTransactionList(loanIdList,pricingDetailsByLoanIdMap, postedTransactionsList);
        pendingTransactionsList.addAll(nlsPostedTransactionList);
        pendingTransactionsList.addAll(voidedTransactionsList);
        
        
        return LoanServicingHelper.filterAndSortTransactions(pendingTransactionsList, filterAndSortTrnParamMap);
    }

    
    /**
    * @description - This method return pending, posted and voided transactions from field finance
    * @author Sk Minsar | 03-15-2024 
    * @param fundingTransactionList 
    * @return Map<String, List<Map<String, Object>>> 
    **/
    private static Map<String, List<Map<String, Object>>> getAllTransactionsMap(List<genesis__Funding_Transaction__c> fundingTransactionList){
        Map<String, List<Map<String, Object>>> allTransactionsMap = new Map<String, List<Map<String, Object>>>();
        List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>>();
        List<Map<String, Object>> pendingTransactionsList = new List<Map<String, Object>>();
        List<Map<String, Object>> voidedTransactionsList = new List<Map<String, Object>>();
        String createdDate = null;

        for(genesis__Funding_Transaction__c fundingTransaction : fundingTransactionList){

            Map<String, Object> allTransactionMap = new Map<String, Object>();

            allTransactionMap.put(PortalConstants.KEY_GROWER_NAME, fundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name);
            allTransactionMap.put(PortalConstants.KEY_LAON_NUMBER, fundingTransaction.Pricing_Detail__r.Loan_Number__c);
            allTransactionMap.put(PortalConstants.KEY_LOAN_ID, fundingTransaction.Pricing_Detail__r.Loan_Id__c);
            allTransactionMap.put(PortalConstants.KEY_DESCRIPTION, fundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c);
            allTransactionMap.put(PortalConstants.KEY_RATE, fundingTransaction.Pricing_Detail__r.genesis__Interest_Rate__c);
            allTransactionMap.put(PortalConstants.KEY_AMOUNT, fundingTransaction.genesis__Amount__c);
            allTransactionMap.put(PortalConstants.KEY_TRANSACTION_TYPE, fundingTransaction.genesis__Payment_Mode__r.Name);
            allTransactionMap.put(PortalConstants.KEY_PURPOSE, fundingTransaction.genesis__Reference__c);
            allTransactionMap.put(PortalConstants.KEY_CREATED_DATE, fundingTransaction.createdDate);
            allTransactionMap.put(PortalConstants.KEY_POSTED_DATE, fundingTransaction.Posted_Date__c);
            allTransactionMap.put(PortalConstants.KEY_STATUS, LoanServicingHelper.getStatus((String)fundingTransaction.Status__c, fundingTransaction.Posted_to_NLS__c));

            
            if(allTransactionMap.get(PortalConstants.KEY_STATUS).equals(PortalConstants.STATUS_POSTED)){
                postedTransactionsList.add(allTransactionMap);
            }else if(allTransactionMap.get(PortalConstants.KEY_STATUS).equals(PortalConstants.STATUS_VOIDED)){
                voidedTransactionsList.add(allTransactionMap);
            }else{
                pendingTransactionsList.add(allTransactionMap);
            }
        }
        allTransactionsMap.put(PortalConstants.POSTED_TRANSACTION_LIST, postedTransactionsList);
        allTransactionsMap.put(PortalConstants.VOIDED_TRANSACTION_LIST, voidedTransactionsList);
        allTransactionsMap.put(PortalConstants.PENDING_TRANSACTION_LIST, pendingTransactionsList);
        return allTransactionsMap;
    }


    /**
    * @description - This method fetch transactions from NLS and format the responses
    * @author Sk Minsar | 03-19-2024 
    * @param loanList 
    * @param pricingDetailsByLoanIdMap 
    * @param ftPostedTransactionsList 
    * @return List<Map<String, Object>> 
    **/
    private List<Map<String, Object>> getPostedTransactionList(List<String> loanList, Map<String,Map<String,Object>> pricingDetailsByLoanIdMap, List<Map<String, Object>> ftPostedTransactionsList) {
            Map<String, Object> parseResponse = new Map<String, Object>();
            List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>>();
            
            List<String> loanIdList = loanList;
            parseResponse = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod(currentUserList[0].accountId, 
                                                                                              loanIdList);
            List<Object> parseResponseList = new List<Object>((List<Object>)parseResponse.get(PortalConstants.KEY_POSTED_TRANSACTIONS));
            List<Map<String, Object>> allPostedTransactionsList = ftPostedTransactionsList;
            for(Object data: parseResponseList){
                Map<String, Object> transactionDataMap = new Map<String, Object>();
                transactionDataMap.put( PortalConstants.KEY_TRANSACTION_CODE ,(Integer)((Map<String,Object>)data).get(PortalConstants.KEY_TRANSACTION_CODE));
                transactionDataMap.put( PortalConstants.KEY_TRANSREF_NUM ,(Integer)((Map<String,Object>)data).get(PortalConstants.KEY_TRANSREF_NUM));
                transactionDataMap.put( PortalConstants.KEY_REVERSAL_TRANSREF ,(Integer)((Map<String,Object>)data).get(PortalConstants.KEY_REVERSAL_TRANSREF));
                transactionDataMap.put( PortalConstants.KEY_LOAN_GROUP ,(Integer)((Map<String,Object>)data).get(PortalConstants.KEY_LOAN_GROUP));
                transactionDataMap.put( PortalConstants.KEY_LOAN_PARTICIPANTS ,(Boolean)((Map<String,Object>)data).get(PortalConstants.KEY_LOAN_PARTICIPANTS));

                if(isValidTransaction(transactionDataMap)){

                    String loanId = String.valueOf((Integer)((Map<String, Object>)data).get(PortalConstants.KEY_ACCTREFNO));
                    String paymentMethodReference = (String)((Map<String, Object>)data).get(PortalConstants.KEY_PAYMENT_METHOD_REFERENCE);
                    Double amount = (Double)((Map<String, Object>)data).get(PortalConstants.KEY_TRANSACTION_AMOUNT);
                    String transactionType = LoanServicingHelper.getPostedTransactionType((String)((Map<String, Object>)data).get(PortalConstants.KEY_TRANSACTION_DESCRIPTIOIN), paymentMethodReference);
                    String postedTransactionDateStr = (String)((Map<String, Object>)data).get(PortalConstants.KEY_TRANSACTION_DATE);
                    Datetime postedTransactionDate = getFormatedDatetime(postedTransactionDateStr);
                    Map<String, Object> postedTransactionMap = new Map<String, Object>();
                    postedTransactionMap.put(PortalConstants.KEY_LOAN_ID, loanId);
                    postedTransactionMap.put(PortalConstants.KEY_TRANSACTION_TYPE, transactionType);
                    postedTransactionMap.put(PortalConstants.KEY_PAYMENT_METHOD_REFERENCE, paymentMethodReference);
                    postedTransactionMap.put(PortalConstants.KEY_AMOUNT, amount);
                    postedTransactionMap.put(PortalConstants.KEY_POSTED_DATE, postedTransactionDate);
                    postedTransactionMap.put(PortalConstants.KEY_STATUS, PortalConstants.STATUS_POSTED);
                    postedTransactionMap.put(PortalConstants.KEY_PURPOSE, (String)((Map<String, Object>)data).get(PortalConstants.KEY_USER_REFERENCE));
                    postedTransactionMap.put(PortalConstants.KEY_DESCRIPTION, pricingDetailsByLoanIdMap.get(loanId).get(PortalConstants.KEY_DESCRIPTION));
                    postedTransactionMap.put(PortalConstants.KEY_GROWER_NAME, pricingDetailsByLoanIdMap.get(loanId).get(PortalConstants.KEY_GROWER_NAME));
                    postedTransactionMap.put(PortalConstants.KEY_LAON_NUMBER, pricingDetailsByLoanIdMap.get(loanId).get(PortalConstants.KEY_LAON_NUMBER));

                    
                    // fetch the rate and created date from field finance
                    Boolean transactionRemoved = false;
                    Integer index = 0;
                    for (Map<String, Object> postedTransaction : allPostedTransactionsList) {
                        String currentLoanId = (String)postedTransaction.get(PortalConstants.KEY_LOAN_ID);
                        Double currentAmount = (Double)postedTransaction.get(PortalConstants.KEY_AMOUNT);
                        String currentTransactionType = (String)postedTransaction.get(PortalConstants.KEY_TRANSACTION_TYPE);
                        Datetime createdDateStr = (Datetime)postedTransaction.get(PortalConstants.KEY_CREATED_DATE);
                        Datetime createdDate = Datetime.valueOfGmt(String.valueOfGmt(createdDateStr));
                        Datetime postedDateStr = (Datetime)postedTransaction.get(PortalConstants.KEY_POSTED_DATE);
                        String postedDateString = String.valueOfGmt(postedDateStr);
                        DateTime postedDate = DateTime.newInstanceGmt(Integer.valueOf(postedDateString.substring(PortalConstants.ZERO_VALUE, PortalConstants.FOUR_VALUE)), Integer.valueOf(postedDateString.substring(PortalConstants.FIVE_VALUE, PortalConstants.SEVEN_VALUE)) , Integer.valueOf(postedDateString.substring(PortalConstants.EIGHT_VALUE, PortalConstants.TEN_VALUE)));

                        if ((loanId.equals(currentLoanId)) 
                                && (amount.equals(currentAmount)) 
                                && (transactionType.equals(currentTransactionType)) 
                                && ((postedTransactionDate.dateGmt()).equals(postedDate.dateGmt()))) {
                            postedTransactionMap.put(PortalConstants.KEY_CREATED_DATE, createdDate);
                            postedTransactionMap.put(PortalConstants.KEY_RATE, postedTransaction.get(PortalConstants.KEY_RATE));
                            transactionRemoved = true;
                            allPostedTransactionsList.remove(index);
                            break;
                        }
                        index++;
                    }
                    if(!transactionRemoved){
                        postedTransactionMap.put(PortalConstants.KEY_RATE, pricingDetailsByLoanIdMap.get(loanId).get(PortalConstants.KEY_RATE));
                        postedTransactionMap.put(PortalConstants.KEY_CREATED_DATE, postedTransactionDate);
                    }
                    
                    postedTransactionsList.add(postedTransactionMap);
                }
            }
        return postedTransactionsList;

    }

    /**
    * @description - This method return pricingIdList and LoanIdList
    * @author Sk Minsar | 03-15-2024 
    * @param applicationId 
    * @param loanDescription 
    * @return Map<String, List<String>> 
    **/
    private static Map<String,List<String>> getPricingLoanIdMap(String applicationId, String loanDescription){
        Map<String,List<String>> pricingLoanIdMap = new  Map<String,List<String>>();
        List<String> loanIdList = new List<String>();
        List<String> pricingIdList = new List<String>();
        List<genesis__Application_Pricing_Detail__c> pricingLoanIdList = new List<genesis__Application_Pricing_Detail__c>();
        if(!loanDescription.equals(PortalConstants.ALL_SUB_TRANCHES)){
            pricingLoanIdList = [SELECT Id,
                                           Loan_Id__c 
                                           FROM genesis__Application_Pricing_Detail__c 
                                           WHERE Loan_Number_Description__c =: loanDescription
                                           AND genesis__Application__c =: applicationId
                                           AND genesis__Enabled_Flag__c = true ];
        }else{
            pricingLoanIdList = [SELECT Id,
                                           Loan_Id__c 
                                           FROM genesis__Application_Pricing_Detail__c 
                                           WHERE genesis__Application__c =: applicationId
                                           AND genesis__Enabled_Flag__c = true ];
        }
        for(genesis__Application_Pricing_Detail__c pricingDetail: pricingLoanIdList){
            if(pricingDetail!=null && !String.isBlank(pricingDetail.Loan_Id__c)){
                loanIdList.add(pricingDetail.Loan_Id__c);
            }
            if(pricingDetail!=null && !String.isBlank(pricingDetail.Id)){
                pricingIdList.add(pricingDetail.Id);
            }
        }
        pricingLoanIdMap.put(PortalConstants.LOAN_ID_LIST, loanIdList);
        pricingLoanIdMap.put(PortalConstants.PRICING_ID_LIST, pricingIdList);
        return pricingLoanIdMap;
    }

    /**
    * @description - This method returns pricing details with loanid key map
    * @author Sk Minsar | 03-15-2024 
    * @param loanIdList 
    * @return Map<String, Map<String, Object>> 
    **/
    private static Map<String,Map<String,Object>> getPricingDetailsByLoanIdMap(List<String> loanIdList){
        Map<String,Map<String,Object>> pricingDetailsByLoanIdMap = new Map<String,Map<String,Object>>();
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = new List<genesis__Application_Pricing_Detail__c>();
        
        pricingDetailsList = [SELECT Id,
                                        genesis__Application__r.genesis__Account__r.Name,
                                        Loan_Number__c,
                                        Loan_Id__c,
                                        genesis__Rate_Card_Setup_Detail__r.Description__c,
                                        genesis__Interest_Rate__c
                                        FROM genesis__Application_Pricing_Detail__c 
                                        WHERE Loan_Id__c IN:loanIdList
                                        AND genesis__Enabled_Flag__c = true ];

        for(genesis__Application_Pricing_Detail__c pricingDetail: pricingDetailsList){
            Map<String, Object> pricingDeatailMap = new Map<String, Object>();
            pricingDeatailMap.put(PortalConstants.KEY_GROWER_NAME, pricingDetail.genesis__Application__r.genesis__Account__r.Name);
            pricingDeatailMap.put(PortalConstants.KEY_LAON_NUMBER, pricingDetail.Loan_Number__c);
            pricingDeatailMap.put(PortalConstants.KEY_DESCRIPTION, pricingDetail.genesis__Rate_Card_Setup_Detail__r.Description__c);
            pricingDeatailMap.put(PortalConstants.KEY_RATE, pricingDetail.genesis__Interest_Rate__c);
            pricingDetailsByLoanIdMap.put((String)pricingDetail.Loan_Id__c, pricingDeatailMap);
        }
        return pricingDetailsByLoanIdMap;
    }

    /**
    * @description - This method gives String Date (like '2024-03-18T02:00:37') to Datetime
    * @author Sk Minsar | 03-18-2024 
    * @param dateTimeStr 
    * @return Datetime 
    **/
    private static Datetime getFormatedDatetime(String dateTimeStr){
        String dateTimeString = dateTimeStr;
        List<String> dateTimeParts = dateTimeString.split(PortalConstants.T_STRING);
        List<String> dateParts = dateTimeParts[0].split(ConstantValues.HYPHEN_STRING);
        
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        
        Datetime dt = Datetime.newInstanceGmt(year, month, day);
        return dt;
    }

    /**
    * @description - this method checks valid transactions
    * @author Sk Minsar | 03-20-2024 
    * @param transactionDataMap 
    * @return Boolean 
    **/
    private Boolean isValidTransaction(Map<String, Object> transactionDataMap) {
        Integer transactionCode = (Integer) transactionDataMap.get(PortalConstants.KEY_TRANSACTION_CODE);
        Integer reversalTransref = (Integer) transactionDataMap.get(PortalConstants.KEY_REVERSAL_TRANSREF);
        Integer loanGroupNo = (Integer) transactionDataMap.get(PortalConstants.KEY_LOAN_GROUP);
        Boolean participantDetailFlag = (Boolean) transactionDataMap.get(PortalConstants.KEY_LOAN_PARTICIPANTS);

        return (math.mod(transactionCode, PortalConstants.TWO_VALUE) == PortalConstants.ZERO_VALUE 
                && !transactionCodeSet.contains(transactionCode) 
                && reversalTransref==PortalConstants.ZERO_VALUE 
                && (participantDetailFlag==false && transactionLoanSet.contains(loanGroupNo)));
    }
    
}