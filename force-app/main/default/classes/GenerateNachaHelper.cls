/**
 * @description       : Generate Nacha File
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 03-06-2024
 * @last modified by  :  Pritam Roy
**/
public inherited sharing class GenerateNachaHelper {
    //Constants specific to the class
    private static final String ERROR_MESSAGE = 'Nacha Arguments not found';
    private static final String FIRST_COLUMN = 'FIRST_COLUMN';
    private static final String SECOND_COLUMN = 'SECOND_COLUMN';
    private static final String THIRD_COLUMN = 'THIRD_COLUMN';
    private static final String FOURTH_COLUMN = 'FOURTH_COLUMN';
    private static final String FIFTH_COLUMN = 'FIFTH_COLUMN';
    private static final String SIXTH_COLUMN = 'SIXTH_COLUMN';
    private static final String SEVENTH_COLUMN = 'SEVENTH_COLUMN';
    private static final String CSV_HEADER = 'CSV_HEADER';

    //Constants specific to the class
     /**
     * @description check for empty variable
     * @param objVariable
     */
    private static void checkVariable(Object objVariable){
        if(objVariable == null){
            throw new CustomException(ERROR_MESSAGE);
        }
    }
    /**
     * @description check for empty list
     * @param objList
     */
    private static void checkEmptyList(List<Object> objList){
        if(objList.isEmpty()){
            throw new CustomException(ERROR_MESSAGE);
        }
    }
    /**
     * @description ignore escape sequence characters
     * @param cellData
     * @return String
     */
    private static String escapeSequence(Object cellData) {
        String cellString = (cellData == null) ?
                '' :
                '\"' + String.valueOf(cellData).replace('\"', '\"\"') + '\"';
    
        return cellString;
    }
    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.clcommon__Bank_Account__c.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
     * @description check dynamic nacha arguments
     * @param nachaArgumentsMap
     */
    private static void checkNachaArguments(Map<String,String> nachaArgumentsMap){
        //First Column should contain Routing Number
        if(nachaArgumentsMap.containsKey(FIRST_COLUMN)){
            checkVariable(nachaArgumentsMap.get(FIRST_COLUMN));
        }
        //Second Column should contain Bank Account Number
        if(nachaArgumentsMap.containsKey(SECOND_COLUMN)){
            checkVariable(nachaArgumentsMap.get(SECOND_COLUMN));
        }
        //Third Column should contain Bank Account Name
        if(nachaArgumentsMap.containsKey(THIRD_COLUMN)){
            checkVariable(nachaArgumentsMap.get(THIRD_COLUMN));
        }
        //Fourth Column should contain Bank Account Type
        if(nachaArgumentsMap.containsKey(FOURTH_COLUMN)){
            checkVariable(nachaArgumentsMap.get(FOURTH_COLUMN));
        }
        //Fifth Column may contain Dealer Name or Grower Name based on Preferences
        if(nachaArgumentsMap.containsKey(FIFTH_COLUMN)){
            checkVariable(nachaArgumentsMap.get(FIFTH_COLUMN));
        }
        //Sixth Column may contain Dealer CIF or Loan Number based on Preferences
        if(nachaArgumentsMap.containsKey(SIXTH_COLUMN)){
            checkVariable(nachaArgumentsMap.get(SIXTH_COLUMN));
        }
        //Seventh Column should contain Total Amount
        if(nachaArgumentsMap.containsKey(SEVENTH_COLUMN)){
            checkVariable(nachaArgumentsMap.get(SEVENTH_COLUMN));
        }
        //Should contain Nacha File Header
        if(nachaArgumentsMap.containsKey(CSV_HEADER)){
            checkVariable(nachaArgumentsMap.get(CSV_HEADER));
        }
    }
    /**
     * @description generate nacha file
     * @param nachaPaymentList
     * @param nachaArgumentsMap
     * @return String
     */
    public static String getNacha(List<AggregateResult> nachaPaymentList,Map<String,String> nachaArgumentsMap){
        checkAccessOnObjects();
        //check dynamic nacha arguments
        checkNachaArguments(nachaArgumentsMap);
        //check for empty list
        checkEmptyList(nachaPaymentList);
        String finalString = '';
        String bankAccountId = '';
        String bankAccountNumber = '';
        String amountString;
        String personName = '';
        String recordString = '';
        String formattedAmount = '';
        String paymentAmountStr = '';
        String modifiedAmount = '';
        Decimal paymentAmount = 0;
        List<String> bankAccountIdList = new List<String>();
        Map<String,String> bankToAccountNumberMap = new Map<String,String>();
        String columnRoutingNumber = nachaArgumentsMap.get(FIRST_COLUMN);
        String columnBankId = nachaArgumentsMap.get(SECOND_COLUMN);
        String columnBankName = nachaArgumentsMap.get(THIRD_COLUMN);
        String columnAccountType = nachaArgumentsMap.get(FOURTH_COLUMN);
        String columnPersonName = nachaArgumentsMap.get(FIFTH_COLUMN);
        String columnPersonNumber = nachaArgumentsMap.get(SIXTH_COLUMN);
        String totalAmount = nachaArgumentsMap.get(SEVENTH_COLUMN);
        String csvColumnHeader = nachaArgumentsMap.get(CSV_HEADER);
        for(AggregateResult eachBankAccount : nachaPaymentList){
            bankAccountIdList.add(String.valueOf(eachBankAccount.get(columnBankId)));
        }
        List<clcommon__Bank_Account__c> listOfBankAccounts = [SELECT Id,
                                                                    clcommon__Bank_Account_Number__c
                                                                FROM clcommon__Bank_Account__c
                                                                WHERE Id IN :bankAccountIdList];
        for(clcommon__Bank_Account__c eachBankAccount : listOfBankAccounts ){
            bankToAccountNumberMap.put(eachBankAccount.Id, eachBankAccount.clcommon__Bank_Account_Number__c);
        }
        finalString = csvColumnHeader;
        for(AggregateResult eachBankPayment: nachaPaymentList){
            bankAccountId = String.valueOf(eachBankPayment.get(columnBankId));
            bankAccountNumber = bankToAccountNumberMap.get(bankAccountId);
            amountString = String.valueOf(eachBankPayment.get(totalAmount));
            personName = String.valueOf(eachBankPayment.get(columnPersonName));
            paymentAmount = 0;
            if(String.isNotBlank(amountString)){
                paymentAmount = Decimal.valueOf(amountString);
            }
            paymentAmountStr = String.valueOf(paymentAmount);
            modifiedAmount = ( Decimal.valueOf(paymentAmountStr==null||paymentAmountStr.trim()==''?'0':paymentAmountStr).setScale(2) + 0.001 ).format();
            formattedAmount = '$'+modifiedAmount.substring(0,modifiedAmount.length()-1);
            recordString =  escapeSequence(String.valueOf(eachBankPayment.get(columnRoutingNumber)))+ ' ' + ','
                                    + escapeSequence(bankAccountNumber)+',' 
                                    + escapeSequence(String.valueOf(eachBankPayment.get(columnBankName)))+','
                                    + escapeSequence(eachBankPayment.get(columnAccountType))+','
                                    + escapeSequence(personName)+','
                                    + escapeSequence(eachBankPayment.get(columnPersonNumber))+','
                                    + escapeSequence(formattedAmount)+'\n';
            finalString = finalString + recordString;
        }
        return finalString; 
    }
}