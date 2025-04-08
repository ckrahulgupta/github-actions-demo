/**
 * @description       : Helper class to create ivoice and related method
 * @author            : Suraj Kumar | 11-26-2024
 * @group             : 
 * @last modified on  : 01-30-2025
 * @last modified by  : Ayush Kumar Singh
**/
public inherited sharing class PaymentInvoiceHelper {

    /**
    * @description : Method to create Invoice
    * @author Sk Minsar | 12-13-2024 
    * @param applicationId 
    * @param paymentMode 
    * @return clcommon__Consolidated_Invoice__c 
    **/
    public static clcommon__Consolidated_Invoice__c createInvoice(String applicationId, String paymentMode) {
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        invoiceObj.Application__c = applicationId;
        invoiceObj.clcommon__Status__c = ConstantValues.STATUS_PENDING;
        invoiceObj.Payment_Mode__c = paymentMode;
        invoiceObj.Invoice_Date__c = System.now();
        Database.Insert(invoiceObj,ConstantValues.TRUE_VALUE);
        return invoiceObj;
    }

    
    /**
    * @description - Create invoice for Request Advance
    * @author Sk Minsar | 12-13-2024 
    * @param applicationId 
    * @param paymentMode 
    * @param totalAmount 
    * @return clcommon__Consolidated_Invoice__c 
    **/
    public static clcommon__Consolidated_Invoice__c createInvoice(String applicationId, String paymentMode, Decimal totalAmount) {
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        invoiceObj.Application__c = applicationId;
        invoiceObj.Total_Amount__c = totalAmount;
        invoiceObj.clcommon__Status__c = ConstantValues.STATUS_PENDING;
        invoiceObj.Payment_Mode__c = paymentMode;
        invoiceObj.Invoice_Date__c = System.now();
        Database.Insert(invoiceObj,ConstantValues.TRUE_VALUE);
        return invoiceObj;
    }

    /**
    * @description - Updating total amount in invoice
    * @author Sk Minsar | 12-06-2024 
    * @param invoiceId 
    * @param totalAmount 
    **/
    public static void updateInvoice(Id invoiceId, Decimal totalAmount) {
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c(Id = invoiceId);
        invoiceObj.Total_Amount__c = totalAmount;
        Database.Update(invoiceObj,ConstantValues.TRUE_VALUE);
    }

    
    
    /**
    * @description -  Creating invoice for Imported csv
    * @author Sk Minsar | 12-10-2024 
    * @param paymentMode 
    * @param loanDetailsMap 
    * @return Map<String, String> 
    **/
    public static Map<String, String> createInvoiceForImportedCSV(String paymentMode, Map<String, Map<String,String>> loanDetailsMap){
        List<clcommon__Consolidated_Invoice__c> invoiceList = new List<clcommon__Consolidated_Invoice__c>();
        Map<String, String> invoiceLoanMap = new Map<String, String>();
        for(String key : loanDetailsMap.keySet()){
            clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
            invoiceObj.Application__c = loanDetailsMap.get(key).get(ConstantValues.APPLICATION_ID_KEY);
            invoiceObj.clcommon__Status__c = ConstantValues.STATUS_PENDING;
            invoiceObj.Payment_Mode__c = paymentMode;
            invoiceObj.Total_Amount__c = Decimal.valueOf(loanDetailsMap.get(key).get(ConstantValues.KEY_AMOUNT));
            invoiceObj.Invoice_Date__c = System.now();
            invoiceList.add(invoiceObj);
        }
        Database.Insert(invoiceList,ConstantValues.TRUE_VALUE);
        invoiceList = [ SELECT Id,
                               Application__r.genesis__Loan_Number__c
                        FROM clcommon__Consolidated_Invoice__c
                        WHERE Id IN :invoiceList ];

        for(clcommon__Consolidated_Invoice__c invoiceObj : invoiceList){
            invoiceLoanMap.put(invoiceObj.Application__r.genesis__Loan_Number__c, invoiceObj.Id);
        }
        return invoiceLoanMap;
    }

    
    /**
    * @description - This method update or delete the funding transactions
    * @author Sk Minsar | 12-13-2024 
    * @param invoiceId 
    * @param paymentMode 
    * @param amount 
    **/
    public static void updateOrDeleteInvoice(Id invoiceId, String paymentMode, Decimal amount){
        if(paymentMode.equals(ConstantValues.PRODUCT_RETURN)){
            Database.delete(invoiceId, ConstantValues.TRUE_VALUE);
            return;
        }
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id,
                                                                                Invoice__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE Invoice__c = :invoiceId];
        if(fundingTransactionList.size()<=1){
            Database.delete(invoiceId, ConstantValues.TRUE_VALUE);
            return;
        }
        List<clcommon__Consolidated_Invoice__c> invoiceListToUpdate = [SELECT Id,
                                                                              Total_Amount__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        WHERE Id = :invoiceId];

        invoiceListToUpdate[0].Total_Amount__c -= amount;
        Database.update(invoiceListToUpdate[0],ConstantValues.TRUE_VALUE);
    }

    /**
    * @description - This method is used to update Invoice Status
    * @author Sk Minsar | 12-12-2024 
    * @param invoiceIdList 
    * @param status 
    **/
    public static void updateInvoiceStatus(List<Id> invoiceIdList, String status){
        List<AggregateResult> clearOrPostTraxList = new List<AggregateResult>();
        if(invoiceIdList.size()<1){
            return;
        }

        List<AggregateResult> totalTransactionList = [
            SELECT Invoice__c Id, COUNT(Id) totalCount
            FROM genesis__Funding_Transaction__c
            WHERE Invoice__c IN :invoiceIdList
            GROUP BY Invoice__c
        ];
        
        clearOrPostTraxList = getClearOrPostTransactionList(invoiceIdList, status);
        
        Map<Id, Integer> totalTransactionMap = new Map<Id, Integer>();
        Map<Id, Integer> clearOrPostTransactionMap = new Map<Id, Integer>();

        for (AggregateResult result : totalTransactionList) {
            totalTransactionMap.put((Id) result.get(ConstantValues.ID_KEY), (Integer) result.get(ConstantValues.KEY_TOTAL_COUNT));
        }

        for (AggregateResult result : clearOrPostTraxList) {
            clearOrPostTransactionMap.put((Id) result.get(ConstantValues.ID_KEY), (Integer) result.get(ConstantValues.KEY_CLEAR_OR_POST_COUNT));
        }

        Set<Id> invoicesToUpdateIds = new Set<Id>();
        for (Id invoiceId : totalTransactionMap.keySet()) {
            if (totalTransactionMap.get(invoiceId) == clearOrPostTransactionMap.get(invoiceId)) {
                invoicesToUpdateIds.add(invoiceId);
            }
        }

        if (!invoicesToUpdateIds.isEmpty()) {
            List<clcommon__Consolidated_Invoice__c> invoicesToUpdate = [
                SELECT Id, clcommon__Status__c
                FROM clcommon__Consolidated_Invoice__c
                WHERE Id IN :invoicesToUpdateIds
            ];

            for (clcommon__Consolidated_Invoice__c invoice : invoicesToUpdate) {
                invoice.clcommon__Status__c = status;
            }
            Database.update(invoicesToUpdate, ConstantValues.TRUE_VALUE);
        }
    }       
    
    /**
    * @description - Method to Add & Update Invoice Id Set
    * @author Sk Minsar | 12-12-2024 
    * @param invoiceId 
    * @param invoiceIdSet 
    * @return Set<Id> 
    **/
    public static Set<Id> addInvoiceIdSet(Id invoiceId, Set<Id> invoiceIdSet){
        if(!String.isBlank(invoiceId)){
            invoiceIdSet.add(invoiceId);
        }
        return invoiceIdSet;
    }

    
    /**
    * @description - Get Cleared or Posted Transaction List
    * @author Sk Minsar | 12-12-2024 
    * @param invoiceIdList 
    * @param status 
    * @return List<AggregateResult> 
    **/
    public static List<AggregateResult> getClearOrPostTransactionList(List<Id> invoiceIdList, String status){
        if(status.equals(ConstantValues.STATUS_INITIATED)){
            return [ SELECT Invoice__c Id, COUNT(Id) clearOrPostCount FROM genesis__Funding_Transaction__c WHERE Invoice__c IN :invoiceIdList AND genesis__Cleared__c = :ConstantValues.TRUE_VALUE AND Posted_to_NLS__c = :ConstantValues.FALSE_VALUE GROUP BY Invoice__c];
        }
        return [SELECT Invoice__c Id, COUNT(Id) clearOrPostCount FROM genesis__Funding_Transaction__c WHERE Invoice__c IN :invoiceIdList AND genesis__Cleared__c = :ConstantValues.TRUE_VALUE AND Posted_to_NLS__c = :ConstantValues.TRUE_VALUE GROUP BY Invoice__c ];
    }

    /**
    * @description 
    * @author Sk Minsar | 12-16-2024 
    * @param invoiceList 
    **/
    public static void updateInvoiceTotalAmounts(List<clcommon__Consolidated_Invoice__c> invoiceList){
        LoanServicingHelper.checkEmptyList(invoiceList, CustomMessageConstants.NO_INVOICE_RECORD_FOUND);
        List<clcommon__Consolidated_Invoice__c> invoicesToUpdate = new List<clcommon__Consolidated_Invoice__c>();
        Map<Id, AggregateResult> fundingTrxTotalMap = new Map<Id, AggregateResult>(
            [ 
                SELECT Invoice__r.Id, SUM(Principal_Paid__c) totalPrincipal, 
                       SUM(Interest_Paid__c) totalInterest, 
                       SUM(Fees_Paid__c) totalFees, 
                       SUM(genesis__Amount__c) totalAmount
                FROM genesis__Funding_Transaction__c
                WHERE Invoice__c IN :invoiceList
                GROUP BY Invoice__r.Id
            ]
        );
        for (clcommon__Consolidated_Invoice__c invoiceObj : invoiceList) {
            if (fundingTrxTotalMap.containsKey(invoiceObj.Id)) {
                AggregateResult agFundingTrxTotal = fundingTrxTotalMap.get(invoiceObj.Id);
                Decimal calculatedPrincipal = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_PRINCIPAL);
                Decimal calculatedInterest = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_INTEREST);
                Decimal calculatedFees = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_FEES);
                Decimal calculatedAmount = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_AMOUNT);
                if (calculatedPrincipal != invoiceObj.Total_Principal__c || 
                    calculatedInterest != invoiceObj.Total_Interest__c || 
                    calculatedFees != invoiceObj.Total_Fees__c || 
                    calculatedAmount != invoiceObj.Total_Amount__c) {
                    
                    invoiceObj = getUpdatedTotalInoiceAmountObj(invoiceObj, agFundingTrxTotal);
                    invoicesToUpdate.add(invoiceObj);
                }
            }
        }
        if (!invoicesToUpdate.isEmpty()) {
            Database.Update(invoicesToUpdate, ConstantValues.TRUE_VALUE);
        }
    }

    
    /**
    * @description - Updates the total amounts in invoice
    * @author Sk Minsar | 12-16-2024 
    * @param invoiceObj 
    * @param agFundingTrxTotal 
    * @return clcommon__Consolidated_Invoice__c 
    **/
    private static clcommon__Consolidated_Invoice__c getUpdatedTotalInoiceAmountObj(clcommon__Consolidated_Invoice__c invoiceObj, AggregateResult agFundingTrxTotal){
        Decimal calculatedPrincipal = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_PRINCIPAL);
        Decimal calculatedInterest = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_INTEREST);
        Decimal calculatedFees = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_FEES);
        Decimal calculatedAmount = (Decimal) agFundingTrxTotal.get(ConstantValues.KEY_TOTAL_AMOUNT);
        List<String> advancesPaymentModeList = new List<String>{
            ConstantValues.ACH,
            ConstantValues.DRAFT,
            ConstantValues.PRODUCT_RETURN
        };
        if(advancesPaymentModeList.contains(invoiceObj.Payment_Mode__r.Name)){
            invoiceObj.Total_Amount__c = calculatedAmount;
        }else{
            invoiceObj.Total_Principal__c = calculatedPrincipal;
            invoiceObj.Total_Interest__c = calculatedInterest;
            invoiceObj.Total_Fees__c = calculatedFees;
            invoiceObj.Total_Amount__c = calculatedPrincipal+calculatedInterest+calculatedFees;
        }
        return invoiceObj;
    }

    /**
     * @description purpose of this method is to export the invoice as PDF
     * @author Rahul Gupta | 01-17-2025 
     * @param invoiceId 
     * @return  `PageReference`
     */
    public static PageReference exportInvoiceAsPDF(Id invoiceId) {

        String logo = '';

        List<clcommon__Consolidated_Invoice__c> invoiceList = [

                        SELECT Id,
                                Application__c,
                                Application__r.Id,
                                Application__r.genesis__Loan_Number__c,
                                Application__r.genesis__Contact__r.Name,
                                Application__r.Dealer_Name__r.Coop_Type__c,
                                Total_Amount__c,
                                Invoice_Date__c,
                                Invoice_Number__c,
                                Comment__c,
                                Application__r.Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                Application__r.Dealer_Name__r.CFA_Partner_Program__r.Grower_Portal_Logo__c,
                                Payment_Mode__r.Name
                        FROM clcommon__Consolidated_Invoice__c
                        WHERE Id = :invoiceId
                        LIMIT 1
                ];

        LoanServicingHelper.checkEmptyList(invoiceList, ConstantValues.INVALID_INVOICE);

        DateTime invoiceCreatedDate = invoiceList[0]?.Invoice_Date__c;
        invoiceCreatedDate = Datetime.valueOfGmt(invoiceCreatedDate.format(ConstantValues.DATE_TIME_FORMAT));

        List<genesis__Funding_Transaction__c> fundingTransactionList = [
                        
                        SELECT Id,
                                Pricing_Detail__r.Loan_Number__c,
                                genesis__Reference__c,
                                Principal_Paid__c,
                                Interest_Paid__c,
                                Fees_Paid__c,
                                genesis__Amount__c,
                                Paid_By_Dealer__c
                        FROM genesis__Funding_Transaction__c
                        WHERE Invoice__c = :invoiceId
                        ORDER BY Pricing_Detail__r.Loan_Number__c
                ];

        LoanServicingHelper.checkEmptyList(fundingTransactionList, ConstantValues.NO_TRANSACTION_DATA);

        List<Profile> profileList = [

                        SELECT Id, 
                               Name 
                        FROM Profile 
                        WHERE Id = :UserInfo.getProfileId()
                        LIMIT 1
                ];

        LoanServicingHelper.checkEmptyList(profileList, PortalConstants.SOMETHING_WENT_WRONG);

        Boolean showComment = PortalConstants.TRUE_VALUE;

        if ((profileList[0].Name == PortalConstants.GROWER_PROFILE || 
             profileList[0].Name == PortalConstants.GMK_GROWER_PROFILE) && 
             String.isBlank(invoiceList[0].Comment__c)) {

            showComment = PortalConstants.FALSE_VALUE;
        }

        if (fundingTransactionList[0].Paid_By_Dealer__c == true && invoiceList[0].Application__r.Dealer_Name__r.Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE) {
            // use dealer logo
            logo = ConstantValues.KEY_RESOURCE + String.valueOf(invoiceList[0]?.Application__r?.Dealer_Name__r?.CFA_Partner_Program__r?.Dealer_Portal_Logo__c);
        } else {
            // use grower logo
            logo = ConstantValues.KEY_RESOURCE + String.valueOf(invoiceList[0]?.Application__r?.Dealer_Name__r?.CFA_Partner_Program__r?.Grower_Portal_Logo__c);
        }

        List<Map<String, Object>> transactions = new List<Map<String,Object>>();

        for (genesis__Funding_Transaction__c transactionDetail : fundingTransactionList) {

            transactions.add(getTransactionDetailMap(transactionDetail));

        }

        pageReference pdfPage = Page.PaymentReceipt;
         
        pdfPage.getParameters().put(PortalConstants.KEY_LOAN_NUMBER, String.valueOf(invoiceList[0].Application__r.genesis__Loan_Number__c));
        pdfPage.getParameters().put(PortalConstants.KEY_GROWER_NAME, String.valueOf(invoiceList[0].Application__r.genesis__Contact__r.Name));
        pdfPage.getParameters().put(PortalConstants.KEY_PAYMENT_MODE, String.valueOf(invoiceList[0].Payment_Mode__r.Name));
        pdfPage.getParameters().put(PortalConstants.KEY_COOP_TYPE, String.valueOf(invoiceList[0].Application__r.Dealer_Name__r.Coop_Type__c));

        pdfPage.getParameters().put(PortalConstants.KEY_IS_PAID_BY_DEALER, String.valueOf(fundingTransactionList[0].Paid_By_Dealer__c));
        pdfPage.getParameters().put(PortalConstants.KEY_TOTAL_AMOUNT, String.valueOf(invoiceList[0].Total_Amount__c));
        pdfPage.getParameters().put(PortalConstants.KEY_CREATED_DATE, String.valueOf(invoiceCreatedDate));
        pdfPage.getParameters().put(PortalConstants.KEY_TRASACTION_NUMBER, String.valueOf(invoiceList[0].Invoice_Number__c));
        pdfPage.getParameters().put(PortalConstants.KEY_SHOW_COMMENT, String.valueOf(showComment));
        pdfPage.getParameters().put(PortalConstants.KEY_COMMENTS, String.valueOf(invoiceList[0].Comment__c));
        pdfPage.getParameters().put(PortalConstants.KEY_LOGO, logo);

        pdfPage.getParameters().put(PortalConstants.KEY_TRANSACTIONS, JSON.serialize(transactions));


        return pdfPage;
    
    }

    /**
    * @description purpose of this method is to convert the funding transaction instance into a map
    * @author Rahul Gupta | 01-20-2025 
    * @param  transactionDetail 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getTransactionDetailMap(genesis__Funding_Transaction__c transactionDetail) {

        Map<String, Object> transactionMap = new Map<String, Object> {
            
            PortalConstants.KEY_LOAN_NUMBER     => PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_PRINCIPAL       => 0.00,
            PortalConstants.KEY_INTEREST        => 0.00,
            PortalConstants.KEY_FEES            => 0.00,
            PortalConstants.KEY_AMOUNT          => 0.00,
            PortalConstants.KEY_DESCRIPTION     => PortalConstants.EMPTY_STRING
        };

        if (transactionDetail.Pricing_Detail__r?.Loan_Number__c != null) {
            transactionMap.put(PortalConstants.KEY_LOAN_NUMBER, transactionDetail.Pricing_Detail__r.Loan_Number__c);
        }

        if (transactionDetail.Principal_Paid__c != null) {
            transactionMap.put(PortalConstants.KEY_PRINCIPAL, transactionDetail.Principal_Paid__c);
        }

        if (transactionDetail.Interest_Paid__c != null) {
            transactionMap.put(PortalConstants.KEY_INTEREST, transactionDetail.Interest_Paid__c);
        }

        if (transactionDetail.Fees_Paid__c != null) {
            transactionMap.put(PortalConstants.KEY_FEES, transactionDetail.Fees_Paid__c);
        }

        if (transactionDetail.genesis__Amount__c != null) {
            transactionMap.put(PortalConstants.KEY_AMOUNT, transactionDetail.genesis__Amount__c);
        }

        if (transactionDetail.genesis__Reference__c != null) {
            transactionMap.put(PortalConstants.KEY_DESCRIPTION, transactionDetail.genesis__Reference__c);
        }

        return transactionMap;
    }
}