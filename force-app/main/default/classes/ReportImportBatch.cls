/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public with sharing class ReportImportBatch implements Database.Batchable<Map<String, Object>> {

    private static final String PARTICIPANT_DAILY = 'PARTICIPANT DAILY';
    private static final String PARTICIPANT_PREFIX = 'participant-';

    Integer month;
    Integer year;
    Id fileId;

    /**
    * @description 
    * @author Rahul Gupta | 12-25-2023 
    * @param fileId 
    * @param month 
    * @param year 
    **/
    public ReportImportBatch(Id fileId, Integer month, Integer year) {
        this.fileId = fileId;
        this.month = month;
        this.year = year;
    }

    /**
    * @description 
    * @author Rahul Gupta | 12-25-2023 
    * @param context 
    * @return Iterable 
    **/
    public Iterable<Map<String, Object>> start(Database.BatchableContext context) {

        List<Map<String, Object>> fullData = new List<Map<String, Object>>();

        // get the CSV data in List<Map<String,Object>
        List<Document> data = [
            SELECT Id,
                    Body 
            FROM Document 
            WHERE Id = :fileId
        ];

        List<String> unparsedData = data[0].Body.toString().split('\n');
        // remove the header row
        unparsedData.remove(0);

        for (String line : unparsedData) {
            String[] columns = line.split(',');
            Map<String, Object> row = new Map<String, Object>();
            row.put('loan_number', columns[0]);
            row.put('interest_balance', columns[1]);
            row.put('monthly_interest', columns[2]);
            row.put('principal', columns[3]);

            fullData.add(row);
        }

        // return the data as iterable
        return fullData;
    }


    /**
    * @description 
    * @author Rahul Gupta | 12-25-2023 
    * @param context 
    * @param chunk 
    **/
    public void execute(Database.BatchableContext context, List<Map<String, Object>> chunk) {

        try {

            Map<String, Map<String, Object>> chunkMap = new Map<String, Map<String, Object>>();
            for (Map<String, Object> row : chunk) {
                chunkMap.put((String) row.get('loan_number'), row);

            }

            List<String> loanNumbers = new List<String>(
                chunkMap.keySet()
            );

            List<genesis__Application_Pricing_Detail__c> pricings = [
                SELECT Id, Loan_Number__c, genesis__Application__c
                FROM genesis__Application_Pricing_Detail__c
                WHERE Loan_Number__c IN :loanNumbers
                AND genesis__Enabled_Flag__c = true
            ];

            List<genesis__Application_Fee_Payment__c> feePayments = new List<genesis__Application_Fee_Payment__c>();

            for (genesis__Application_Pricing_Detail__c pricing : pricings) {

                if (!chunkMap.containsKey((String) pricing.Loan_Number__c)) {
                    continue;
                }

                genesis__Application_Fee_Payment__c feePayment = new genesis__Application_Fee_Payment__c();
                feePayment.Pricing_Detail__c = pricing.Id;
                feePayment.genesis__Application__c = pricing.genesis__Application__c;
                feePayment.Dealer_Monthly_Interest__c = 
                        Decimal.valueOf((String) chunkMap.get((String) pricing.Loan_Number__c).get('interest_balance'));
                feePayment.Interest_Earned__c = 
                        Decimal.valueOf((String) chunkMap.get((String) pricing.Loan_Number__c).get('monthly_interest'));
                feePayment.Principal_Balance__c = 
                        Decimal.valueOf((String) chunkMap.get((String) pricing.Loan_Number__c).get('principal'));
                feePayment.Month__c = month;
                feePayment.Year__c = year;
                feePayment.Record_Type__c = PARTICIPANT_DAILY;
                feePayment.External_Id__c = PARTICIPANT_PREFIX + pricing.Id + '-' 
                + String.valueOf(year) + '-'
                + String.valueOf(year) 
                + month;

                feePayments.add(feePayment);

            }

            Database.UpsertResult[] results = 
                        Database.upsert(feePayments, genesis__Application_Fee_Payment__c.External_Id__c, false);

            String errors = '=======>> ';
            Boolean containErrors = false;

            for (Database.UpsertResult result : results) {
                if (!result.isSuccess()) {
                    errors += result + ' || ';
                    containErrors = true;
                }
            }

            if (containErrors) {
                clcommon__Log__c log = new clcommon__Log__c();
                log.Name = ReportImportBatch.class.toString();
                log.clcommon__Message__c = errors;
                log.clcommon__Time__c = System.now();

                Database.insert(log, true);
            }


        } catch (Exception e) {
            PortalHelper.saveExceptionLog(e, ReportImportBatch.class.toString());
        }
    }

    /**
    * @description 
    * @author Rahul Gupta | 12-25-2023 
    * @param context 
    **/
    public void finish(Database.BatchableContext context) {
        try {
            // get the old pricings
            List<genesis__Application_Pricing_Detail__c> oldPricings = [
                SELECT Id, Loan_Number__c
                FROM genesis__Application_Pricing_Detail__c
                WHERE CALENDAR_MONTH(genesis__Rate_Card_Setup_Detail__r.End_Date__c) = :month
                AND CALENDAR_YEAR(genesis__Rate_Card_Setup_Detail__r.End_Date__c) = :year
            ];

            List<String> loanNumbers = new List<String>();

            Map<String, genesis__Application_Pricing_Detail__c> pricingMap = new Map<String, genesis__Application_Pricing_Detail__c>();

            for (genesis__Application_Pricing_Detail__c oldPricing : oldPricings) {
                loanNumbers.add(oldPricing.Loan_Number__c);
                pricingMap.put((String) oldPricing.Loan_Number__c, oldPricing);
            }

            List<genesis__Application_Fee_Payment__c> incorrectFeePayments = [
                SELECT Id, Pricing_Detail__c, Pricing_Detail__r.Loan_Number__c
                FROM genesis__Application_Fee_Payment__c
                WHERE Pricing_Detail__r.Loan_Number__c IN :loanNumbers
                AND Month__c = :month
                AND Year__c = :year
                AND Record_Type__c = :PARTICIPANT_DAILY
            ];
            
            List<genesis__Application_Fee_Payment__c> correctFeePayments = new List<genesis__Application_Fee_Payment__c>();

            for (genesis__Application_Fee_Payment__c incorrectFeePayment : incorrectFeePayments) {

                if (!pricingMap.containsKey((String) incorrectFeePayment.Pricing_Detail__r.Loan_Number__c)) {
                    continue;
                }

                genesis__Application_Pricing_Detail__c oldPricing = 
                        pricingMap.get((String) incorrectFeePayment.Pricing_Detail__r.Loan_Number__c);

                if (incorrectFeePayment.Pricing_Detail__c != oldPricing.Id) {
                    incorrectFeePayment.Pricing_Detail__c = oldPricing.Id;
                    correctFeePayments.add(incorrectFeePayment);
                }
                
            }

            Database.update(correctFeePayments, true);


        } catch (Exception e) {
            PortalHelper.saveExceptionLog(e, ReportImportBatch.class.toString());
        }
    }

}