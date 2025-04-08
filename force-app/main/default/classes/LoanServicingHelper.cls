/**
 * @description       : Helper Class For Loan Servicing.
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/
public inherited sharing class LoanServicingHelper {
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String GROWER_EMAIL_TEMPLATE = 'Loan Booked Notification For Grower';
    private static final String REPLACE_LOAN_NUMBER = '{!loanNumber}';
    private static final String CLASS_NAME = LoanServicingHelper.class.getName();
    /**
     * @description Return the NLS Access Token
     * @return  `String`
     * @exception 
     */
    public static String getNLSAccessToken(){
        String accessToken;
        for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
            accessToken = AccessTokenGenerator.getAccessToken();
            if(accessToken != null){
                break;
            }
        }
        if(accessToken == null){
            throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
        }
        return accessToken;
    }
    /**
     * @description store request body in clcommon Log
     * @param type 
     * @param requestBody 
     * @param body 
     */
    public static void storeGenericRequestBody(String type, String requestBody,String body){
        Database.insert(new clcommon__Log__c(Name = type + requestBody ,
        clcommon__Message__c = type + requestBody 
        + body,
        clcommon__Time__c = System.Now()), false); 
        System.debug(' ----- START TIME ----- ');
        System.debug(Limits.getHeapSize());
        System.debug(Limits.getCpuTime());
        logger.info(type + requestBody + body);
        logger.flush();
        System.debug(' ----- STOP TIME ----- ');
        System.debug(Limits.getHeapSize());
        System.debug(Limits.getCpuTime());
    }
    
    /**
     * @description store respose Body in clcommon Log
     * @param type 
     * @param responseBody 
     * @param body 
     */
    public static void storeGenericResponseBody(String type, String responseBody,String body){
        Database.insert(new clcommon__Log__c(Name = type + responseBody ,
        clcommon__Message__c = type + responseBody
        + body,
        clcommon__Time__c = System.Now()), false);
        logger.info(type + responseBody + body);
        logger.flush();
        
    }

    /**
    * @description - This method checks empty String
    * @author Sk Minsar | 03-19-2024 
    * @param input 
    * @param exceptionNameString 
    **/
    public static void checkEmptyString(String input, String exceptionNameString){
        if(String.isBlank(input)){
            throw new CustomException(exceptionNameString);
        }
    }

    /**
    * @description - This method return formated status
    * @author Sk Minsar | 03-15-2024 
    * @param status 
    * @param isPostedToNLS  
    * @return String 
    **/
    public static String getStatus(String status, Boolean isPostedToNLS){

        if(String.isBlank(status)){
            return PortalConstants.STATUS_PENDING;
        }else if(status.equals(PortalConstants.STATUS_VOIDED)){
            return status;
        }else if(isPostedToNLS){
            return PortalConstants.STATUS_POSTED;
        }

        return PortalConstants.STATUS_PENDING;
    }

   
    /**
    * @description - This method helps to check poste Transaction's type
    * @author Sk Minsar | 03-19-2024 
    * @param transactionType 
    * @param paymentMethodReference 
    * @return String 
    **/
    public static String getPostedTransactionType(String transactionType, String paymentMethodReference){
        if(!String.isBlank(paymentMethodReference)){
            if(paymentMethodReference.equals(PortalConstants.NLS_ACH_COMMERCE)){
                return ConstantValues.PAYMENT;
            }else if(paymentMethodReference.equals(PortalConstants.NLS_CHECK_COMMERCE)){
                return ConstantValues.MOBILE_DEPOSIT;
            }
        }
        else if(transactionType.equals(PortalConstants.NLS_DRAFT_ADVANCE)){
            return ConstantValues.DRAFT;
        }else if(transactionType.equals(PortalConstants.NLS_PRINCIPAL_ADVANCE)){
            return ConstantValues.ACH;
        }else if(transactionType.equals(PortalConstants.NLS_PRODUCT_RETURN)){
            return ConstantValues.PRODUCT_RETURN;
        }
        return transactionType;
    }



    
    /**
    * @description - This method helps to filter and sort transactions
    * @author Sk Minsar | 03-22-2024 
    * @param postedTransactionsList 
    * @param filterAndSortTrnParamMap 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> filterAndSortTransactions(List<Map<String, Object>> postedTransactionsList, Map<String, String> filterAndSortTrnParamMap ) {
        String inputFromDate = filterAndSortTrnParamMap.get(PortalConstants.KEY_FROM_DATE);
        String inputToDate = filterAndSortTrnParamMap.get(PortalConstants.KEY_TO_DATE);
        String dealerCoopType = filterAndSortTrnParamMap.get(ConstantValues.DEALER_COOP_TYPE);
        List<Map<String, Object>> finalTransactionsList = new List<Map<String, Object>>();
        List<String> fromDateList;
        List<String> toDateList;
        Datetime fromDate;
        Datetime toDate;

        if (!isEmptyString(inputFromDate, inputToDate)) {
            fromDateList = inputFromDate.split(PortalConstants.SLASH_STRING);
            toDateList = inputToDate.split(PortalConstants.SLASH_STRING);
            fromDate = DateTime.newInstanceGmt(Integer.valueOf(fromDateList[2]), Integer.valueOf(fromDateList[0]), Integer.valueOf(fromDateList[1]));
            toDate = DateTime.newInstanceGmt(Integer.valueOf(toDateList[2]), Integer.valueOf(toDateList[0]), Integer.valueOf(toDateList[1]));
            for (Map<String, Object> singleTransaction : postedTransactionsList) {
                DateTime createdDateDt = (DateTime) singleTransaction.get(PortalConstants.KEY_CREATED_DATE);
                String createdDateString = String.valueOfGmt(createdDateDt);
                DateTime createdDate = DateTime.newInstanceGmt(Integer.valueOf(createdDateString.substring(PortalConstants.ZERO_VALUE, PortalConstants.FOUR_VALUE)), Integer.valueOf(createdDateString.substring(PortalConstants.FIVE_VALUE, PortalConstants.SEVEN_VALUE)) , Integer.valueOf(createdDateString.substring(PortalConstants.EIGHT_VALUE, PortalConstants.TEN_VALUE)));

                if ((createdDate.DateGmt() >= fromDate.DateGmt()) && ((createdDate.DateGmt()<= toDate.DateGmt()))) {
                    finalTransactionsList.add(singleTransaction);
                }
            }
        } else {

            finalTransactionsList.addAll(postedTransactionsList);
        }
        
        finalTransactionsList = excludeGmkDraftTransactions(finalTransactionsList, dealerCoopType);
        
        for (Integer firstIndex = 0; firstIndex < finalTransactionsList.size() - 1; firstIndex++) {
            for (Integer secondIndex = firstIndex + 1; secondIndex < finalTransactionsList.size(); secondIndex++) {
                DateTime firstDate = (DateTime) finalTransactionsList[firstIndex].get(PortalConstants.KEY_CREATED_DATE);
                DateTime secondDate = (DateTime) finalTransactionsList[secondIndex].get(PortalConstants.KEY_CREATED_DATE);
                if (firstDate < secondDate) {
                    Map<String, Object> temp = finalTransactionsList[firstIndex];
                    finalTransactionsList[firstIndex] = finalTransactionsList[secondIndex];
                    finalTransactionsList[secondIndex] = temp;
                }
            }
        }
        
        return finalTransactionsList;
    }
     
    /**
    * @description : check string is empty or not
    * @author Sk Minsar | 03-21-2024 
    * @param input 
    * @param secondInput 
    * @return Boolean 
    **/
    public static Boolean isEmptyString(String input, String secondInput){
        if(!String.isBlank(input)  && !String.isBlank(secondInput)){
            return false;
        }
        return true;
    }
    
    /**
    * @description - This method used to excluded the DRAFT transactions for Gmk
    * @author Sk Minsar | 03-22-2024 
    * @param finalTransactionsList 
    * @param dealerCoopType 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> excludeGmkDraftTransactions(List<Map<String, Object>> finalTransactionsList, String dealerCoopType){
        if (dealerCoopType.equals(PortalConstants.GROWMARK_COOP_TYPE)) {
            List<Map<String, Object>> excludedTransactionsList = new List<Map<String, Object>>();
            for (Map<String, Object> singleTransaction : finalTransactionsList) {
                String transactionType = (String)singleTransaction.get(PortalConstants.KEY_TRANSACTION_TYPE);
                if (!transactionType.equals(PortalConstants.DRAFT)) {
                    excludedTransactionsList.add(singleTransaction);
                }
            }
            return excludedTransactionsList;
        }
        return finalTransactionsList;
    }

    /**
    * @description : This methos is used to send the email to Landus Grower when application gets booked.
    * @author Suraj Kumar | 04-30-2024 
    * @param applicationObj 
    **/
    public static void sendEmailToLandusGrower(genesis__Applications__c applicationObj){
        Map<String, Object> notificationMap = new Map<String, Object>();
        if(!applicationObj.Coop_Type__c.equals(PortalConstants.LANDUS_COOP_TYPE)){
            return;
        }
        String emailStatus = PortalConstants.EMPTY_STRING;
        String logoName = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c;
        Messaging.SendEmailResult[] result;
        List<String> recipientAddressList = getRecipientAddress(applicationObj);
        if(recipientAddressList.size() == 0){
            // Keeping Log for not sending email
            clcommon__Log__c logObj = EmailUtil.getUnsentEmailLog(GROWER_EMAIL_TEMPLATE,ConstantValues.EMAIL_MISSING+PortalConstants.HYPHEN_STRING+applicationObj.Name);
            Database.insert(logObj,true);
            return;
        }
        if(applicationObj.genesis__Loan_Number__c == null){
            // Keeping Log for not sending email
            clcommon__Log__c logObj = EmailUtil.getUnsentEmailLog(GROWER_EMAIL_TEMPLATE,ConstantValues.LOAN_NUMBER_MISSING+PortalConstants.HYPHEN_STRING+applicationObj.Name);
            Database.insert(logObj,true);
            return;
        }
        String loanNumber = applicationObj.genesis__Loan_Number__c;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplateObj = EmailUtil.getEmailTemplate(GROWER_EMAIL_TEMPLATE);

        List<OrgWideEmailAddress> senderAddressList = EmailUtil.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
        if(senderAddressList.size() ==0){
            // Keeping Log for not sending email
            clcommon__Log__c logObj = EmailUtil.getUnsentEmailLog(GROWER_EMAIL_TEMPLATE,ConstantValues.SENDER_MISSING+PortalConstants.HYPHEN_STRING+applicationObj.Name);
            Database.insert(logObj,true);
            return;
        }
        email.setOrgWideEmailAddressId(senderAddressList[0].Id);

        email.subject = emailTemplateObj.subject;
        String emailBody = emailTemplateObj.HtmlValue;
        emailBody = emailBody.replace(REPLACE_LOAN_NUMBER, loanNumber);
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, ConstantValues.LOGO_BASE_URL + logoName);
        email.setHtmlBody(emailBody);
        email.setToAddresses(recipientAddressList);
        result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        emailStatus = result[0].isSuccess()?ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
        notificationMap.put(ConstantValues.KEY_FROM_ADDRESS, senderAddressList[0].Address);
        notificationMap.put(ConstantValues.KEY_TO_ADDRESS, recipientAddressList[0]);
        notificationMap.put(ConstantValues.KEY_EMAIL_TEMPLATE, GROWER_EMAIL_TEMPLATE);
        notificationMap.put(ConstantValues.KEY_MESSAGE, emailBody);
        notificationMap.put(ConstantValues.KEY_CLASS_NAME, CLASS_NAME);
        notificationMap.put(ConstantValues.KEY_EMAIL_STATUS, emailStatus);
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            notificationMap.put(ConstantValues.KEY_ERROR_MESSAGE, result[0].getErrors().get(0).getMessage());
        }
        // method to save email Log
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(notificationMap);
        if(notificationObj != null){
            Database.insert(notificationObj,true);
        }
    }

     /**
    * @description : This method is used to validate the application object for sending Email to Landus Grower and return the receiver Email Id.
    * @author Suraj Kumar | 04-30-2024 
    * @param applicationObj 
    * @return List<String> 
    **/
    private static List<String> getRecipientAddress(genesis__Applications__c applicationObj){
        List<String> recipientAddressList = new List<String>();
        if(applicationObj.genesis__Account__c == null
                || applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c == null){
            return recipientAddressList;
        }

        List<clcommon__Party__c> principalPartyTypeList = [SELECT Id,
                                                                    clcommon__Contact__c,
                                                                    clcommon__Contact__r.Email 
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__c = :applicationObj.Id
                                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME
                                                                AND Principal_Number__c = 1];

        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            if(applicationObj.genesis__Contact__c != null && applicationObj.genesis__Contact__r.Email != null){
                recipientAddressList.add(applicationObj.genesis__Contact__r.Email);
            }
        }
        else if(principalPartyTypeList.size() == 1 
                && principalPartyTypeList[0].clcommon__Contact__c != null 
                && principalPartyTypeList[0].clcommon__Contact__r.Email != null){
            recipientAddressList.add(principalPartyTypeList[0].clcommon__Contact__r.Email);
        }
        return recipientAddressList;
    }

    /**
    * @description : Method to validate loan Id
    * @author Suraj Kumar | 05-02-2024 
    * @param loanId 
    **/
    public static void validateLoanId(String loanId){
        if(loanId == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description Purpose of this method is to insert the exception logs handled in the Apex Classes
    * @author Rakesh Saraf | 10-01-2024 
    * @param objException 
    * @param exceptionNameString 
    **/
    public static void saveExceptionLog(Exception objException, String exceptionNameString){
        Database.Insert(new clcommon__Log__c(Name = exceptionNameString ,
                                            clcommon__Message__c = exceptionNameString 
                                            + objException.getStackTraceString()
                                            + objException.getMessage(),
                                            clcommon__Time__c = System.Now()), false,AccessLevel.SYSTEM_MODE);
        Logger.error(objException);
        Logger.flush(); 
    }

    /**
    * @description : Method to validate past due loan
    * @author Suraj Kumar | 11-29-2024 
    * @param currentLoanList 
    **/
    public static void validatePastDueLoan(List<genesis__Applications__c> currentLoanList){
        List<genesis__Applications__c> previousApplicationList = [SELECT Id
                                                                        FROM genesis__Applications__c
                                                                        WHERE genesis__Maturity_Date__c < :currentLoanList[0].genesis__Maturity_Date__c
                                                                        AND genesis__Account__c = :currentLoanList[0].genesis__Account__c
                                                                        AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                        AND Past_Due_Amount__c > 0];
        if(previousApplicationList.size() > 0){
            throw new CustomException(PortalConstants.PREVIOUS_LOAN_PAYOFF_ERROR);
        }
    }

    /**
    * @description 
    * @author Sk Minsar | 12-01-2023 
    * @param amount 
    * @return Boolean 
    **/
    public static Boolean isNotNumeric(String amount){
        Boolean returnValue;
        try{
            Decimal.valueOf(amount);
            returnValue = FALSE; 
        } catch (Exception e) {
            returnValue = TRUE;
        }
        return returnValue;
    }   
    /**
    * @description - The purpose of this method is to get LoggedIn user's Dealer
    * @author Sk Minsar | 10-30-2023 
    * @return Id 
    **/
    public static String getLoggedInUserDealerId() {
        List<User> objLoggedInUserList = [SELECT Id,
                                                ContactId,
                                                AccountId,
                                                Account.ParentId
                                        FROM USER
                                        WHERE Id = :UserInfo.getUserId()
                                        LIMIT 1];
        if (objLoggedInUserList.isEmpty() || objLoggedInUserList[0].Account.ParentId==null) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return String.valueOf(objLoggedInUserList[0].Account.ParentId);
    }


    /**
    * @description - The Purpose of this method is to get parent loan number

    * @author Sk Minsar | 10-30-2023 
    * @param childLoanNumber 
    * @return String 
    **/
    public static String getParentLoanNumberMap(String childLoanNumber){
        if(!childLoanNumber.contains('-')){
            return childLoanNumber;
        }
        String[] parts = childLoanNumber.split('-');
        if (parts.size() > 0) {
            String numericPart = parts[0].replaceAll('[^0-9]', '');
            return numericPart;
        }
        
        return childLoanNumber;
    }
    /**
    * @description - Purpose of this method is to Handle and parse csv file with comma
    * @author Sk Minsar | 10-04-2023 
    * @param csvFileLine 
    * @return List<String> 
    **/
    public static List<String> getCommaEscapedRecord(String csvFileLine){

        List<String> csvRecordList = new List<String>();
        Boolean insideQuotes = false;
        String currentElement = '';
        
        for (Integer ch = 0; ch < csvFileLine.length(); ch++) {
            String character = csvFileLine.substring(ch, ch + 1);
            
            if (character == '"') {
                insideQuotes = !insideQuotes;
            } else if (character == ',' && !insideQuotes) {
                csvRecordList.add(currentElement.replaceAll('"', '').trim());
                currentElement = '';
            } else {
                currentElement += character;
            }
        }
        
        // Add the last element after the loop
        csvRecordList.add(currentElement.replaceAll('"', '').trim());
        csvRecordList[2]=csvRecordList[2].replace(',','');
        return csvRecordList;
    }

    /**
    * @description - The purpose of this method is to insure the CSV File is valid or not
    * @author Sk Minsar | 10-10-2023 
    * @param csvRecordData 
    **/
    public static void isValidateCSVRecordData(String[] csvRecordData){
        if(csvRecordData.size() !=3){
            throw new CustomException(PortalConstants.INVALID_CSV);
        }
        else if(String.isEmpty(csvRecordData[0]) || String.isEmpty(csvRecordData[1]) || String.isEmpty(csvRecordData[2]) || String.valueOf(csvRecordData[2]).equalsIgnoreCase('\r')){
            throw new CustomException(PortalConstants.CSV_FILE_FIELD_MISSING);
        }
    }
    /**
    * @description - The purpose of this method is to get the Desired CSV file Uploaded from the portal
    * @author Sk Minsar | 10-10-2023 
    * @param argumentsFromPortal 
    * @return List<String> 
    **/
    public static List<String> getcsvFileLinesList(Map<String, Object> argumentsFromPortal){
        String contentDocumentLinkId;
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
        ContentVersion objContentVersion = new ContentVersion();
        String csvAsString;
        List<String> csvFileLinesList = new List<String>();

            contentDocumentLinkId = String.valueOf(argumentsFromPortal.get(PortalConstants.ID_KEY));
            if(contentDocumentLinkId == null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            objContentDocumentLink = [SELECT Id, 
                                            contentDocumentID 
                                    FROM ContentDocumentLink where Id =: contentDocumentLinkId];

            if(objContentDocumentLink == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            objContentVersion = [SELECT Id, 
                                        ContentDocumentId, 
                                        VersionData,
                                        FileType 
                                FROM ContentVersion 
                                WHERE ContentDocumentId =: objContentDocumentLink.contentDocumentID
                                AND IsLatest = true ];
            if(objContentVersion == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            if(String.valueOf(objContentVersion.FileType)!= PortalConstants.KEY_CSV){
                throw new CustomException(PortalConstants.INVALID_CSV_FILE);
            }
            csvAsString = objContentVersion.VersionData.toString();
            csvFileLinesList = csvAsString.split('\n');
            return csvFileLinesList;
    }

    /**
    * @description 
    * @author Sk Minsar | 12-01-2023 
    * @param objPricingDetails 
    * @param amount 
    **/
    public static void sufficientFundCheck(genesis__Application_Pricing_Detail__c objPricingDetails,Decimal amount){

        if(objPricingDetails.genesis__Application__r.Available__c < amount){
            throw new CustomException(PortalConstants.INSUFFICIENT_AVAILABLE_FUNDS + PortalConstants.ACH_LOAN_NUMBER + objPricingDetails.Loan_Number__c);
        }
    }
    /**
    * @description - This method checks the amount requested (summation of all sub-tranches including duplicate) and what is available
    * @author Sk Minsar | 10-30-2023 
    * @param parentLoanNumberMap 
    * @param objPricingDetails 
    **/
    public static void sufficientFundCheck(Map<String,String> parentLoanNumberMap,genesis__Application_Pricing_Detail__c objPricingDetails){

        String parentloanNo= getParentLoanNumberMap(String.valueOf(objPricingDetails.Loan_Number__c));
        if(objPricingDetails.genesis__Application__r.Available__c < Decimal.valueOf(parentLoanNumberMap.get(parentloanNo))){
            throw new CustomException(PortalConstants.INSUFFICIENT_AVAILABLE_FUNDS + PortalConstants.ACH_LOAN_NUMBER + parentloanNo);
        }

    }
    /**
    * @description - The Purpose of this class is to validate Loan Number
    * @author Sk Minsar | 10-12-2023 
    * @param csvLoanList 
    **/
    public static void isValidLoanNumber(List<String> csvLoanList){
        List<genesis__Application_Pricing_Detail__c> objPricingList=[SELECT Id,
                                                Loan_Number__c
                                        FROM genesis__Application_Pricing_Detail__c
                                        WHERE genesis__Enabled_Flag__c = true
                                        AND genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                        AND Loan_Id__c != null
                                        AND Loan_Number__c IN:csvLoanList
                                        AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()];
            List<String> existingLoanNumbers  = new List<String>();
            for(genesis__Application_Pricing_Detail__c iterPricing:objPricingList){
                existingLoanNumbers.add(iterPricing.Loan_Number__c);
            }
            for(String iterLoan: csvLoanList){
                if(! existingLoanNumbers.contains(iterLoan)){
                    throw new CustomException(PortalConstants.INVALID_LOAN_NUMBER.replace(PortalConstants.REPLACE_LOAN_NUMBER, iterLoan));
                }
            }
    }

 
    /**
    * @description - This method is used to get the filtered CSV data.
    * @author Sk Minsar | 12-10-2024 
    * @param csvFileLinesList 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getFilteredCSVDataMap(List<String> csvFileLinesList){
        Map<String,List<String>> csvLoanAmountMap = new Map<String,List<String>>();
        List<List<String>> allCSVFileLinesList = new List<List<String>>();
        Map<String,String> parentLoanNumberMap = new Map<String,String>();
        Set<String> uniqueLoanSet=new Set<String>();
        Map<String,Map<String,String>> loanDetailsMap = new Map<String,Map<String,String>>();
        List<String> csvLoanList = new List<String>();
        for(Integer index=1; index < csvFileLinesList.size(); index++){
            String[] csvRecordData = LoanServicingHelper.getCommaEscapedRecord(csvFileLinesList[index]);
            LoanServicingHelper.isValidateCSVRecordData(csvRecordData);
            
            if(LoanServicingHelper.isNotNumeric(csvRecordData[2])) {
                throw new CustomException(PortalConstants.AMOUNT_FORMAT + PortalConstants.ACH_LOAN_NUMBER + csvRecordData[0]);
            }

            //Storing Duplicate childLoan Sum in a list
            if(!csvLoanAmountMap.containsKey(csvRecordData[0])){
                csvLoanAmountMap.put(csvRecordData[0],new List<String>{csvRecordData[1],csvRecordData[2]});
            }
            else {
                csvLoanAmountMap.put(csvRecordData[0],new List<String>{csvRecordData[1],String.valueOf(Decimal.valueOf(csvLoanAmountMap.get(csvRecordData[0])[1]) + Decimal.valueOf(csvRecordData[2]))});
            }
            //Storing all Duplicate Loan including with ChildLoan Sum
            String parentLoan = LoanServicingHelper.getParentLoanNumberMap(csvRecordData[0]);
            if(!parentLoanNumberMap.containsKey(parentLoan)){
                parentLoanNumberMap.put(parentLoan, csvRecordData[2]);
            }else{
                parentLoanNumberMap.put(parentLoan, String.valueOf(Decimal.valueOf(parentLoanNumberMap.get(parentLoan)) + Decimal.valueOf(csvRecordData[2])));
            }
            loanDetailsMap.put(parentLoan, new Map<String,String>{
                PortalConstants.KEY_AMOUNT => parentLoanNumberMap.get(parentLoan),
                PortalConstants.APPLICATION_ID_KEY => null
                }
            );
            
            uniqueLoanSet.add(csvRecordData[0]);
            csvLoanList.add(csvRecordData[0]);
            //adding all loan number, purpose, amount in a list
            allCSVFileLinesList.add(new List<String>{csvRecordData[0],csvRecordData[1],csvRecordData[2]});
        }
        return new Map<String,Object> {
            PortalConstants.KEY_CSV_LOAN_AMOUNT_MAP => csvLoanAmountMap,
            PortalConstants.KEY_ALL_CSV_FILE_LINES_LIST => allCSVFileLinesList,
            PortalConstants.KEY_PARENT_LOAN_NUMBER_MAP => parentLoanNumberMap,
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoanSet,
            PortalConstants.KEY_LOAN_DETAILS_MAP => loanDetailsMap,
            PortalConstants.KEY_CSV_LOAN_LIST => csvLoanList
        };
    }

    
    /**
    * @description - Used to validate Loan Details & return loanDetailsMap
    * @author Sk Minsar | 12-10-2024 
    * @param loanDetailsParamMap 
    * @return Map<String,Map<String,String>>
    **/
    public static Map<String,Map<String,String>> validateLoanDetails(Map<String, Object> loanDetailsParamMap){

        List<genesis__Application_Pricing_Detail__c> objPricingDetailsList = (List<genesis__Application_Pricing_Detail__c>)loanDetailsParamMap.get(PortalConstants.KEY_OBJ_PRICING_DETAILS_LIST);
        Map<String,Map<String,String>> loanDetailsMap = (Map<String,Map<String,String>>)loanDetailsParamMap.get(PortalConstants.KEY_LOAN_DETAILS_MAP);
        Map<String,List<String>> csvLoanAmountMap = (Map<String,List<String>>)loanDetailsParamMap.get(PortalConstants.KEY_CSV_LOAN_AMOUNT_MAP);
        Map<String,String> parentLoanNumberMap = (Map<String,String>)loanDetailsParamMap.get(PortalConstants.KEY_PARENT_LOAN_NUMBER_MAP);

        for(genesis__Application_Pricing_Detail__c objPricingDetails:objPricingDetailsList){
            loanDetailsMap.get(LoanServicingHelper.getParentLoanNumberMap(String.valueOf(objPricingDetails.Loan_Number__c))).put(PortalConstants.APPLICATION_ID_KEY, String.valueOf(objPricingDetails.genesis__Application__r.Id));
            Decimal amount = Decimal.valueOf(String.valueOf(csvLoanAmountMap.get(objPricingDetails.Loan_Number__c)[1]).replace('\r', ''));
            if(amount<=0){
                throw new CustomException(PortalConstants.INVALID_LOAN_AMOUNTS + PortalConstants.ACH_LOAN_NUMBER + objPricingDetails.Loan_Number__c);
            }
            Date currentMaturityDate = Date.valueOf(objPricingDetails.genesis__Application__r.genesis__Maturity_Date__c);
            Boolean suspendedStatus = PortalLoanServicingHelper.isCloseToMaturity(currentMaturityDate);
            if(suspendedStatus==true){
                throw new CustomException(PortalConstants.SUSPENDED_LOANS + PortalConstants.ACH_LOAN_NUMBER + objPricingDetails.Loan_Number__c);
            }
            LoanServicingHelper.sufficientFundCheck(objPricingDetails,amount);
            LoanServicingHelper.sufficientFundCheck(parentLoanNumberMap, objPricingDetails);
        }
        return loanDetailsMap;
    }

    /**
    * @description - This method used to validate csv file format
    * @author Sk Minsar | 12-10-2024 
    * @param csvFileLinesList 
    **/
    public static void validateCSVFormat(List<String> csvFileLinesList){
        if(csvFileLinesList.size()==0 || !String.valueOf(csvFileLinesList[0]).Contains(PortalConstants.KEY_IMPORT_ACH_CSV_HEADER)){
            throw new  CustomException(PortalConstants.CSV_HEADER_MISSING_EX);
        }
        if(csvFileLinesList.size()==1){
            throw new CustomException(PortalConstants.CSV_FILE_FIELD_MISSING);
        }
    }

    
    /**
    * @description - Used to check Invalid List of Object & throw exception
    * @author Sk Minsar | 12-10-2024 
    * @param objList 
    * @param exceptionNameString 
    **/
    public static void checkEmptyList(List<Object> objList, String exceptionNameString) {
        if(objList == null || objList.isEmpty()){
            throw new CustomException(exceptionNameString);
        }
    }

    /**
    * @description - This method check and throw exception for close maturity where current date is greater than or equal to 26th and next month is maturity date.
    * @author Sk Minsar | 12-12-2024 
    * @param currentMaturityDate 
    * @param currentdate 
    **/
    public static void validateCloseMaturityProductReturn(Date currentMaturityDate, Date currentdate){
        if(currentMaturityDate.year()-currentdate.year()==1 && currentMaturityDate.month()==1 && currentdate.month()==12 && currentdate.day()>26){
            PortalLoanServicingHelper.throwCustomError(true, PortalConstants.PRODUCT_RETURN_NOT_ALLOWED);
        }
        if((currentMaturityDate.year()-currentdate.year()==0) && (currentMaturityDate.month()-currentdate.month()==1) && currentdate.day()>26){
            PortalLoanServicingHelper.throwCustomError(true, PortalConstants.PRODUCT_RETURN_NOT_ALLOWED);
        }
    }
}