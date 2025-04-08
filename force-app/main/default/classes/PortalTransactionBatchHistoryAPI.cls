/**
 * @description       : Fetch the ACH and Draft batch history
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
**/
global without sharing  class PortalTransactionBatchHistoryAPI implements clcommon.PortalCustomRemoteAPI1 { 

    private static final String KEY_PAYMENT_MODE = 'paymentMode';
    private static final String DRAFT = 'DRAFT';
    private static final String ACH = 'ACH';

    private static final String QUERY_KEY_BATCH_NAME = 'Name';
    private static final String QUERY_KEY_BATCH_STATUS = 'Status__c';
    private static final String QUERY_KEY_BATCH_RECORDED_DATE = 'Recorded_Date__c';
    private static final String QUERY_KEY_BATCH_TOTAL_AMOUNT = 'expr1';
    private static final String QUERY_KEY_BATCH_ID = 'Batch__c';
    private static final String RESP_KEY_BATCH_ID = 'batch_id';
    private static final String RESP_KEY_BATCH_NAME = 'batch_name';
    private static final String RESP_KEY_BATCH_DATE = 'batch_date';
    private static final String RESP_KEY_BATCH_TOTAL_AMOUNT = 'total_amount';
    private static final String RESP_KEY_BATCH_STATUS = 'batch_status';
    private static final String REGEX_ACH = '^ACH-';
    private static final String REGEX_DRAFT = '^DRAFT-';

    private static final String CLASS_NAME = 'PortalTransactionBatchHistoryAPI';

    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    /**
    * @description : Fetch ACH and DRAFT
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        
        SavePoint dbSavePoint = Database.setSavepoint();
        String paymentMode = null;

        try {
            if (request.get(KEY_PAYMENT_MODE) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            } 
            paymentMode = (String) request.get(KEY_PAYMENT_MODE);
            if (!paymentMode.equals(DRAFT) && !paymentMode.equals(ACH)) {
                throw new CustomException(PortalConstants.INVALID_PAYMENT_MODE);
            }
            
            List<User> objUserList = [SELECT AccountId, Account.ParentId FROM User WHERE Id = :UserInfo.getUserId()];
            if (objUserList.size() != 1) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            List<AggregateResult> objFundingTransactionAggregateResultList = [SELECT Count(Id), 
                                                                                     SUM(genesis__Amount__c),
                                                                                     Batch__c,
                                                                                     Batch__r.Name,
                                                                                     Batch__r.Status__c,
                                                                                     Batch__r.Recorded_Date__c
                                                                              FROM genesis__Funding_Transaction__c 
                                                                              WHERE genesis__Application__r.Dealer_Name__c = :objUserList[0].Account.ParentId
                                                                              AND Batch__c != ''
                                                                              AND genesis__Payment_Mode__r.Name = :paymentMode
                                                                              GROUP BY Batch__c, 
                                                                                       Batch__r.Name, 
                                                                                       Batch__r.Status__c,
                                                                                       Batch__r.Recorded_Date__c
                                                                              HAVING SUM(genesis__Amount__c) > 0];
            
            
            Map<String, Object> objFundingTransactionMap = null;

            String batchDate = null;

            for (AggregateResult objFundingTransactionAggregateResult : objFundingTransactionAggregateResultList) {
                objFundingTransactionMap = new Map<String, Object>();

                objFundingTransactionMap.put(RESP_KEY_BATCH_TOTAL_AMOUNT, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_TOTAL_AMOUNT));
                objFundingTransactionMap.put(RESP_KEY_BATCH_ID, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_ID));
                objFundingTransactionMap.put(RESP_KEY_BATCH_NAME, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_NAME));
                objFundingTransactionMap.put(RESP_KEY_BATCH_STATUS, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_STATUS));
                // objFundingTransactionMap.put(RESP_KEY_BATCH_DATE, Date.valueOf(batchDate));
                objFundingTransactionMap.put(RESP_KEY_BATCH_DATE, objFundingTransactionAggregateResult.get(QUERY_KEY_BATCH_RECORDED_DATE));

                responseData.add(new clcommon.PortalCustomRemoteActionRecord(objFundingTransactionMap));
                
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 

        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME); 
        }
        return response;
    }
}