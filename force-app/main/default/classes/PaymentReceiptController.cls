/**
 * @description       : Controller class for PaymentReceipt VF page
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 02-03-2025
 * @last modified by  : Ayush Kumar Singh
**/
public without sharing class PaymentReceiptController {
    
    /**
    * @description : variable to store showComment value for PaymentReceipt VF Page
    **/
    public Map<String, Object> pageParameters{get;set;}

    
    /**
    * @description constructor for the PaymentReceiptController class
    * @author Rahul Gupta | 01-18-2025 
    **/
    public PaymentReceiptController() {
        
        try {
            // extract the page paramters and null checks
            sanitizePageParameters();

            // do proper datatype conversion and formatting
            castToActualDataType();

        } catch(Exception objException){
            PortalHelper.saveExceptionLog(objException, PaymentReceiptController.class.getName());
        }
    }

    /**
    * @description purpose of this method is to sanitize the page parameters
    * @author Rahul Gupta | 01-18-2025 
    **/
    private void sanitizePageParameters() {

        // initialize the empty page parameters map with the required key
        pageParameters = new Map<String, Object> {
            PortalConstants.KEY_LOAN_NUMBER         =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_COOP_TYPE           =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_PAYMENT_MODE        =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_IS_PAID_BY_DEALER   =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_TOTAL_AMOUNT        =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_TRASACTION_NUMBER   =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_COMMENTS            =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_SHOW_COMMENT        =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_LOGO                =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_GROWER_NAME         =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_CREATED_DATE        =>  PortalConstants.EMPTY_STRING,
            PortalConstants.KEY_TRANSACTIONS        =>  new List<Map<String, Object>>()
        };

        for (String key : pageParameters.keySet()) {
            if (Apexpages.currentPage().getParameters().containsKey(key)) {
                pageParameters.put(key, Apexpages.currentPage().getParameters().get(key).escapeHtml4());
            }
        }
    }

    /**
    * @description purpose of this method is to convert and map the page parameters to their actual data type
    * @author Rahul Gupta | 01-18-2025 
    **/
    private void castToActualDataType() {

        if (pageParameters.get(PortalConstants.KEY_IS_PAID_BY_DEALER) != PortalConstants.EMPTY_STRING) {
            pageParameters.put(PortalConstants.KEY_IS_PAID_BY_DEALER, Boolean.valueOf(pageParameters.get(PortalConstants.KEY_IS_PAID_BY_DEALER)));
        }

        if (pageParameters.get(PortalConstants.KEY_SHOW_COMMENT) != PortalConstants.EMPTY_STRING) {
            pageParameters.put(PortalConstants.KEY_SHOW_COMMENT, Boolean.valueOf(pageParameters.get(PortalConstants.KEY_SHOW_COMMENT)));
        }

        if (pageParameters.get(PortalConstants.KEY_CREATED_DATE) != PortalConstants.EMPTY_STRING) {
            pageParameters.put(PortalConstants.KEY_CREATED_DATE, DateTime.valueOf((String) pageParameters.get(PortalConstants.KEY_CREATED_DATE)));
        }

        if (pageParameters.get(PortalConstants.KEY_GROWER_NAME) != PortalConstants.EMPTY_STRING){
            pageParameters.put(PortalConstants.KEY_GROWER_NAME,String.valueOf(pageParameters.get(PortalConstants.KEY_GROWER_NAME)).replace(ConstantValues.ESCAPED_AMPERSAND, ConstantValues.AMPERSAND).replace(ConstantValues.ESCAPED_QUOTE, ConstantValues.DOUBLE_QUOTE).replace(ConstantValues.ESCAPED_SINGLE_QUOTE, ConstantValues.SINGLE_QUOTE).replace(ConstantValues.ESCAPED_LESS_THAN_SIGN, ConstantValues.LESS_THAN_SIGN).replace(ConstantValues.ESCAPED_GREATER_THAN_SIGN,ConstantValues.GREATER_THAN_SIGN));
        }

        if (pageParameters.get(PortalConstants.KEY_COMMENTS) != PortalConstants.EMPTY_STRING){
            pageParameters.put(PortalConstants.KEY_COMMENTS,String.valueOf(pageParameters.get(PortalConstants.KEY_COMMENTS)).replace(ConstantValues.DOUBLE_ESCAPED_AMPERSAND, ConstantValues.AMPERSAND).replace(ConstantValues.DOUBLE_ESCAPED_QUOTE, ConstantValues.DOUBLE_QUOTE).replace(ConstantValues.DOUBLE_ESCAPED_SINGLE_QUOTE, ConstantValues.SINGLE_QUOTE).replace(ConstantValues.ESCAPED_SINGLE_QUOTE, ConstantValues.SINGLE_QUOTE).replace(ConstantValues.ESCAPED_PARAGRAPH_TAG, ConstantValues.EMPTY_STRING).replace(ConstantValues.ESCAPED_CLOSING_PARAGRAPH_TAG,ConstantValues.EMPTY_STRING).replace(ConstantValues.DOUBLE_ESCAPED_GREATER_THAN_SIGN, ConstantValues.GREATER_THAN_SIGN).replace(ConstantValues.DOUBLE_ESCAPED_LESS_THAN_SIGN, ConstantValues.LESS_THAN_SIGN));
        }
        

        List<Object> deserializedTransactions = 
                    (List<Object>) JSON.deserializeUntyped(Apexpages.currentPage().getParameters().get(PortalConstants.KEY_TRANSACTIONS));

        List<Map<String, Object>> transactions = new List<Map<String,Object>>();

        for (Object deserializedTransaction : deserializedTransactions) {

            Map<String, Object> eachTransaction = 
                    (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(deserializedTransaction));

            transactions.add(eachTransaction);
        }

        pageParameters.put(PortalConstants.KEY_TRANSACTIONS, transactions);
    }

}