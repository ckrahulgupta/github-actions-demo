/**
 * @description       : Purpose of this class is to delete a particular record in an object
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Shruti Tamakhuwala
**/
global without sharing class PortalGenericDeleteAPI implements clcommon.PortalCustomRemoteAPI1{
    // Constant portal parameters specific for this class starts
    public static final String KEY_OBJECT = 'objectName';
    public static final String KEY_RECORD = 'recordId';
    public static final String MY_PROGRAM_STRING = 'myProgram';
    public static final String SPECIAL_TRANCHE_STRING = 'specialTermInterest';
    public static final String COLLATERAL_STRING = 'collateral';
    public static final String PARTY_STRING = 'party';
    public static final String BANK_ACCOUNT_STRING = 'bankAccount';
    public static final String FUNDING_TRNX_STRING = 'fundingTransaction';
    public static final String OBJ_COLLATERAL_STRING = 'clcommon__Collateral__c';
    public static final String OBJ_PARTY_STRING = 'clcommon__Party__c';
    public static final String OBJ_RATECARD_HEADER_STRING = 'genesis__rate_card_setup_header__c';
    public static final String OBJ_RATECARD_DETAIL_STRING = 'genesis__Rate_Card_Setup_Detail__c';
    public static final String OBJ_FUNDING_TRNX_STRING = 'genesis__Funding_Transaction__c';
    public static final String OBJ_BANK_ACCOUNT_STRING = 'clcommon__Bank_Account__c';
    private static final String OBJECT_API_NAME = 'objectApiName';
    private static final String ZERO_VALUE = '0';
    private static final String MULTIPLE_DELETE = 'multipleDelete';
    private static final String PAYMENT_OPTION = 'paymentOption';
    private static final String PORTAL = 'Portal';
    private static final String TOTAL_PAYMENT = '{!TotalPayment}';
    private static final String GROWER_NAME = 'Grower Name';
    private static final String COOP_TYPE = 'Coop Type';
    private static final String DELETE_ALL_PENDING_PAYMENT = 'DeleteAllPendingPayment';
    private static final String GROWER_PORTAL = 'GrowerPortal';
    private static final String DEALER_PORTAL = 'DealerPortal';
    private final String CLASS_NAME = PortalGenericDeleteAPI.class.getName(); 
    // Constant portal parameters specific for this class ends
    // Declarations specific to this class Starts
    String objectName = PortalConstants.EMPTY_STRING;
    String recordId = PortalConstants.EMPTY_STRING;
    String applicationId = PortalConstants.EMPTY_STRING;
    Map<String, String> portalArgMapKeyToSobjMap = new Map<String, String> {
        COLLATERAL_STRING => OBJ_COLLATERAL_STRING,
        PARTY_STRING => OBJ_PARTY_STRING,
        MY_PROGRAM_STRING => OBJ_RATECARD_HEADER_STRING,
        SPECIAL_TRANCHE_STRING => OBJ_RATECARD_DETAIL_STRING,
        FUNDING_TRNX_STRING => OBJ_FUNDING_TRNX_STRING,
        BANK_ACCOUNT_STRING => OBJ_BANK_ACCOUNT_STRING
    };
    clcommon.Response responseObj = new clcommon.Response();
    Boolean multipleDelete = false;
    // Declarations specific to this class Ends

    /**
    * @description 
    * @author iAyush | 04-01-2022 
    * @param  componentStrName 
    * @param  disclosureNames 
    * @param  argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames,
                                                Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        try{
            checkNecessaryParam(argumentsFromPortal);
            applicationId = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_ID));

            /* *Checking if the user is allowed to access the application or not */
            userApplicationAccessValidation(objectName, applicationId);
            
            String objectApiName = portalArgMapKeyToSobjMap.get(objectName);
            
            List<genesis__Funding_Transaction__c> currentLoanTransactions = PortalLoanServicingHelper.getCurrentLoanTransactions(
                applicationId
            );
            Decimal totalAmount = calculateTotalAmount(currentLoanTransactions);
            
            String amount = String.valueOf(totalAmount);
            String str = (Decimal.valueOf(amount == null || amount.trim() == PortalConstants.EMPTY_STRING ? ZERO_VALUE : amount).setScale(2) + 0.001).format();
            String fundingamount = str.substring(0, str.length() - 1);
            
            List<User> activeUserList = [SELECT Id, 
                                                    Contact.Account.RecordType.Name
                                            FROM User
                                            WHERE Id = :UserInfo.getUserId()];

            deleteObjectName(new Map<String, String>{
                                OBJECT_API_NAME => objectApiName,
                                PortalConstants.APPLICATION_ID => applicationId,
                                KEY_RECORD  => recordId
                            },argumentsFromPortal);

            List<genesis__Applications__c> currentLoan = [SELECT Id,
                                                                genesis__Maturity_Date__c,
                                                                genesis__Account__c,
                                                                Past_Due_Balance__c,
                                                                Dealer_Name__c,
                                                                Dealer_Name__r.Coop_Type__c,
                                                                genesis__Account__r.Name
                                                        FROM genesis__Applications__c
                                                        WHERE Id = :applicationId
                                                        AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                        LIMIT 1];
            Map<String,String> emailMap = new Map<String,String> {
                                    PAYMENT_OPTION => ((String) argumentsFromPortal.get(PortalConstants.KEY_PAYMENT_MODE)) == null ? ConstantValues.PAYMENT: (String) argumentsFromPortal.get(PortalConstants.KEY_PAYMENT_MODE),
                                    PORTAL => activeUserList[0].Contact.Account.RecordType.Name == PortalConstants.GROWER_PROFILE ? GROWER_PORTAL : DEALER_PORTAL,
                                    TOTAL_PAYMENT => fundingamount,
                                    GROWER_NAME => currentLoan.size() > 0 ? currentLoan[0].genesis__Account__r.Name : PortalConstants.EMPTY_STRING,
                                    COOP_TYPE => currentLoan.size() > 0 ? currentLoan[0].Dealer_Name__r.Coop_Type__c : PortalConstants.CFA_COOP_TYPE
                                };
            PortalLoanServicingHelper.sendEmailToCL(applicationId, DELETE_ALL_PENDING_PAYMENT, emailMap);     
            
            responseObj.status = clcommon.Constants.SUCCESS;
        }
        catch(CustomException ex){
            Database.rollback(dbSavePoint);
            responseObj.status = clcommon.Constants.API_EXCEPTION;
            responseObj.errorMessage = ex.getMessage();
            PortalHelper.saveExceptionLog(ex, CLASS_NAME);
        }
        catch(Exception e){
            Database.rollback(dbSavePoint);
            responseObj.status = clcommon.Constants.API_EXCEPTION;
            responseObj.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(e, CLASS_NAME);
        }
        return responseObj;
    }

    /**
    * @description calculates the total amount
    * @author Soumik Pattanayak | 22-01-2025 
    * @param currentLoanTransactions 
    * @return Decimal 
    **/
    private static Decimal calculateTotalAmount(List<genesis__Funding_Transaction__c> currentLoanTransactions){
        Decimal totalAmount = 0.0;
        for (genesis__Funding_Transaction__c eachFundingTransaction : currentLoanTransactions) {
            totalAmount = totalAmount + eachFundingTransaction.genesis__Amount__c;
        }
        return totalAmount;
    }

    /**
    * @description validate user with application
    * @author Soumik Pattanayak | 22-01-2025 
    * @param objectName 
    * @param applicationId 
    **/
    private static void userApplicationAccessValidation(String objectName, String applicationId){
        if (objectName != MY_PROGRAM_STRING && objectName != SPECIAL_TRANCHE_STRING && objectName != FUNDING_TRNX_STRING && !String.isBlank(applicationId)){
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
        }
    }

    /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param paramMap 
    * @param argumentsFromPortal 
    **/
    public static void deleteObjectName(Map<String, String> paramMap, Map<String, Object> argumentsFromPortal){
        String objectApiName = paramMap.get(OBJECT_API_NAME);
        String applicationId = parammap.get(PortalConstants.APPLICATION_ID);
        String recordId = parammap.get(KEY_RECORD);
        //deleting Additional Info party 
        deleteAppParty(applicationId, recordId, objectApiName);
        
        if(objectApiName == OBJ_COLLATERAL_STRING){

            PortalApplicationOriginationHelper.deleteCollateral(applicationId, recordId);
        }
        
        else if(objectApiName == OBJ_RATECARD_HEADER_STRING){

            PortalApplicationOriginationHelper.deleteRateCardHeader(recordId);
        }
        else if(objectApiName == OBJ_RATECARD_DETAIL_STRING){

            PortalApplicationOriginationHelper.deleteRateCardDetail(recordId);
        }
        else if(objectApiName == OBJ_BANK_ACCOUNT_STRING){

            PortalApplicationOriginationHelper.deleteBankAccount(recordId);
        }
        else if(objectApiName == OBJ_FUNDING_TRNX_STRING){
            if(argumentsFromPortal.containsKey(MULTIPLE_DELETE) && applicationId != null){


                String paymentMode = ((String) argumentsFromPortal.get(PortalConstants.KEY_PAYMENT_MODE)) == null ? ConstantValues.PAYMENT: (String) argumentsFromPortal.get(PortalConstants.KEY_PAYMENT_MODE);

                PortalLoanServicingHelper.deleteMultiFundTrans(applicationId, paymentMode);
            }
            else{
                PortalLoanServicingHelper.deleteFundingTransaction(recordId);
            }
        }
      

    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param argumentsFromPortal 
    **/
    public void checkNecessaryParam(Map<String, Object> argumentsFromPortal){
        if(argumentsFromPortal.get(KEY_OBJECT) == null ||
                argumentsFromPortal.get(KEY_RECORD) == null){
                    throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
         objectName = String.valueOf(argumentsFromPortal.get(KEY_OBJECT));
         recordId = String.valueOf(argumentsFromPortal.get(KEY_RECORD));
            
            
         /** Null Check for all the mandatory input parameters */
        if(String.isBlank(objectName) || String.isBlank(recordId) || !portalArgMapKeyToSobjMap.containsKey(objectName)){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }

    }
    /**
    * @description : Delete Application Party
    * @author  Pritam Roy | 06-12-2024 
    * @param applicationId 
    * @param recordId 
    * @param objectApiName 
    **/
    public static void deleteAppParty(String applicationId,String recordId,String objectApiName){
        if(objectApiName == OBJ_PARTY_STRING){
            PortalApplicationOriginationHelper.deleteparty(applicationId, recordId);
        }
    }
    
}