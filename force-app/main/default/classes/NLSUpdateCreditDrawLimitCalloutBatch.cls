/**
 * @description       : Update credit Total Draw Limit into NLS
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 02-12-2024
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class NLSUpdateCreditDrawLimitCalloutBatch implements Database.Batchable<String>, Database.AllowsCallouts{

    private static final String REPORT_NAME = ConstantValues.PRODUCT_RETURN_POSTED;
    private static final String FOLDER_NAME = ConstantValues.PRODUCT_RETURN_REPORTS;
    private static final String FOLDER_TYPE = 'Document';
    private static final String PRODUCT_RETURN_SUBJECT = 'Product Return Posted Report';
    private static final String REPORT_ID = 'reportID';
    private static final String FOLDER_ID = 'folderID';
    private static final String API_TYPE = 'NLSUpdateCreditTotalDrawLimitAPIType';

    private static final String FUNDING_TRANSACTION_LIST = 'fundingTransactionIdList';
    List<String> fundingTransactionIdList;
    /**
     * @description Constructor which recieve application Id List
     * @param fundingTransactionList 
     */
    public NLSUpdateCreditDrawLimitCalloutBatch(List<String> fundingTransactionList) {
        this.fundingTransactionIdList = fundingTransactionList;
    }
    
    /**
     * @description start method which return application id List
     * @param bc 
     * @return  `Iterable<String>`
     */
    public Iterable<String> start(Database.BatchableContext bc){
        return fundingTransactionIdList;
    }

    /**
     * @description This method used to do callout to update credit total draw limit in NLS
     * @param bc 
     * @param fundingTransactionIdList 
     * @exception 
     */
    public void execute(Database.BatchableContext bc, List<String> fundingTransactionIdList){ 
        try{
            if(fundingTransactionIdList.isEmpty()){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }

            Map<String, Object> requestParamMap = new Map<String, Object>();
            Map<String, Object> queryIdMap = new Map<String, Object>();
            queryIdMap.put(FUNDING_TRANSACTION_LIST, fundingTransactionIdList);
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                API_TYPE,
                                                                                                                            queryIdMap, requestParamMap);

            if(responseObject.getBody() == null){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
        }
        catch(Exception objException){
            PortalHelper.saveExceptionLog(objException, ConstantValues.NLS_CALLOUT);
        }
    }

    
    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        Map<String,Id> typeVsIdMap = new Map<String,Id>();
        List<Report> reportList =  [SELECT  Id,
                                            Name 
                                    FROM Report 
                                    WHERE Name = :REPORT_NAME
                                    LIMIT 1];
            
        List<Folder> folderList =   [SELECT Id,
                                            Name 
                                    FROM Folder 
                                    WHERE Name = :FOLDER_NAME
                                    AND Type =: FOLDER_TYPE
                                    LIMIT 1];

        typeVsIdMap.put(REPORT_ID,(Id) String.valueOf(reportList[0].Id));
        typeVsIdMap.put(FOLDER_ID,(Id) String.valueOf(folderList[0].Id));
        
        //Generate Product Return Posted Document and send it to Loan Accounting
        GenerateProductReturnHandler.createProductReturnDocument(typeVsIdMap,false,PRODUCT_RETURN_SUBJECT);
    }
}