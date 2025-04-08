/**
 * @description       : Purpose of this class is to export applications into CSV and PDF
 * @author            : Tuhin Bhunia
 * Created            : 16-06-2023 
 * @last modified on  : 03-16-2025
 * @last modified by  : Rahul Gorai
**/

global without sharing class PortalGrowmarkExportAPI implements clcommon.PortalCustomRemoteAPI1 {
    // constants specific for this class [start]
    private static final String KEY_APPLICATIONS = 'applications';
    private static final String KEY_EXPORT_TYPE = 'exportType';
    private static final String KEY_DATA_TYPE = 'dataType';
    private static final String SINGLE_QUOTE_STRING = '\'';
    private static final String COMMA_STRING = ',';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String CSV_VALUE = 'csv';
    private static final String PDF_VALUE = 'pdf';
    private static final String APPLICATION_VALUE = 'application';
    private static final String LOAN_VALUE = 'loan';
    
    private static final String APPL_CSV_TABLE_HEADING = 'APP #, LOAN AMOUNT, GROWER NAME, CROP YEAR, TIER, GUARANTY %, STATUS, IRC, Unique Identifier, DATE INITIATED,DATE SUBMITTED\n';
    
    private static final String LOAN_CSV_TABLE_HEADING = 'CROP YEAR, LOAN #, MATURITY DATE, LOAN AMOUNT, GROWER NAME, TIER, GUARANTY %, IRC, Unique Identifier, CERTIFIED LENDER, SALES AGENT\n';

    private static final String APPL_PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body> <h1 style="font-size: 15pt;">Applications</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>APP #</th> <th>LOAN AMOUNT</th> <th>GROWER NAME</th> <th>CROP YEAR</th> <th>TIER</th> <th>GUARANTY %</th> <th>STATUS</th> <th>IRC</th> <th>Unique Identifier</th> <th>DATE INITIATED</th> <th>DATE SUBMITTED</th> </tr>';
    
    private static final String LOAN_PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><body> <h1 style="font-size: 15pt;">Loans</h1> <table border="1" cellpadding="5" style="font-size: 7.5pt;"> <tr style="background-color: rgba(92, 109, 71, 0.31); font-weight: bold;"> <th>CROP YEAR</th><th>LOAN #</th> <th>MATURITY DATE</th> <th>LOAN AMOUNT</th><th>GROWER NAME</th> <th>TIER</th>  <th>GUARANTY %</th> <th>IRC</th> <th>Unique Identifier</th> <th>CERTIFIED LENDER</th> <th>SALES AGENT</th> </tr>';

    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td style="padding: 7.5pt 11.25pt">';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PORTAL_GROWMARK_EXPORT_API = 'PortalGrowmarkExportAPI';
    // constants specific for this class [end]
    
    String applicationDetails = '';
    String exportType = '';
    String dataType = '';
    
    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();


    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param cellData 
    * @return String 
    **/
    private static String createCSVTableRow(Object cellData) {
        String cellString = (cellData == null) ?
                COMMA_STRING :
                '\"' + String.valueOf(cellData).replace('\"', '\"\"') + '\"' + COMMA_STRING;
    
        return cellString;
    }


    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param cellData 
    * @return String 
    **/
    private static String createPDFTableRow(Object cellData) {
        String cellString = (cellData == null) ? 
                        PDF_HTML_TD_START_END : 
                        PDF_HTML_TD_START 
                            + String.valueOf(cellData) 
                            + PDF_HTML_TD_END;
        return cellString;
    }

    /**
    * @description - the purpose of this method is to get the account id of a logged in user
    * @author Sk Minsar | 11-13-2023 
    * @return Id 
    **/
    private static Id getUserAccountId() {
        List<User> objLoggedInUserList = [SELECT Id,
                                                ContactId,
                                                AccountId
                                        FROM USER
                                        WHERE Id = :UserInfo.getUserId()
                                        LIMIT 1];
    
        return objLoggedInUserList.size() != 1 ? null : objLoggedInUserList[0].AccountId;
    }
    
    /**
     * @description 
     * @return  `Id`
     * @exception 
     */
    private static Id getLoggedInUserDealerId() {
        List<User> objLoggedInUserList =[SELECT Id,
                                                ContactId,
                                                AccountId,
                                                Account.ParentId
                                        FROM USER
                                        WHERE Id = :UserInfo.getUserId()
                                        LIMIT 1];
    
        if (objLoggedInUserList.isEmpty() || objLoggedInUserList[0].Account.ParentId==null) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return objLoggedInUserList[0].Account.ParentId;
    }

    
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param partyIdList 
    * @param exportType 
    * @param shouldExportAll 
    **/
    @TestVisible
    private void exportApplications(Set<Id> partyIdList, String exportType, Boolean shouldExportAll) {
        List<clcommon__party__c> objPartyList;
        Id loggedInAccountId = getUserAccountId();

        if (shouldExportAll) {
            objPartyList = [SELECT Id, 
                                    genesis__Application__r.Name, 
                                    genesis__Application__r.genesis__Loan_Amount__c, 
                                    genesis__Application__r.genesis__Account__r.Name, 
                                    genesis__Application__r.Crop_Year__c,
                                    genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                    genesis__Application__r.Guarantee__c, 
                                    genesis__Application__r.genesis__Status__c, 
                                    genesis__Application__r.Internal_Reference_Code__c,
                                    genesis__Application__r.Growmark_Unique_Identifier__c, 
                                    genesis__Application__r.CreatedDate,
                                    genesis__Application__r.Submitted_to_CFA__c
                            FROM clcommon__party__c 
                            WHERE clcommon__Account__r.Id = :loggedInAccountId
                            AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                            AND genesis__Application__r.genesis__Status__c NOT IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                    :PortalConstants.CLOSED_APPLICATION_STATUS,
                                                                                    :PortalConstants.APPROVED_APPLICATION_STATUS)];
        } else {
            objPartyList = [SELECT Id, 
                                    genesis__Application__r.Name, 
                                    genesis__Application__r.genesis__Loan_Amount__c, 
                                    genesis__Application__r.genesis__Account__r.Name, 
                                    genesis__Application__r.Crop_Year__c,
                                    genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                    genesis__Application__r.Guarantee__c, 
                                    genesis__Application__r.genesis__Status__c, 
                                    genesis__Application__r.Internal_Reference_Code__c, 
                                    genesis__Application__r.Growmark_Unique_Identifier__c,
                                    genesis__Application__r.CreatedDate,
                                    genesis__Application__r.Submitted_to_CFA__c
                            FROM clcommon__party__c 
                            WHERE Id IN :partyIdList
                            AND clcommon__Account__r.Id = :loggedInAccountId
                            AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                            AND genesis__Application__r.genesis__Status__c NOT IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                    :PortalConstants.CLOSED_APPLICATION_STATUS,
                                                                                    :PortalConstants.APPROVED_APPLICATION_STATUS)];
        }

        if (objPartyList.size() == 0) {
            throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
        }

        if (exportType.equals(CSV_VALUE)) {
            String tableData = APPL_CSV_TABLE_HEADING;
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (clcommon__party__c objParty : objPartyList) {
                tableRow = createCSVTableRow(objParty.genesis__Application__r.Name)
                                + createCSVTableRow(objParty.genesis__Application__r.genesis__Loan_Amount__c)
                                + createCSVTableRow(objParty.genesis__Application__r.genesis__Account__r.Name)
                                + createCSVTableRow(objParty.genesis__Application__r.Crop_Year__c)
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.genesis__Credit_Rating__r.Name))
                                + createCSVTableRow(objParty.genesis__Application__r.Guarantee__c)
                                + createCSVTableRow(objParty.genesis__Application__r.genesis__Status__c)
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Internal_Reference_Code__c))
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Growmark_Unique_Identifier__c))
                                + createCSVTableRow(PortalReportsHelper.getformatedDate(objParty.genesis__Application__r.CreatedDate))
                                + createCSVTableRow(PortalReportsHelper.getformatedDate(objParty.genesis__Application__r.Submitted_to_CFA__c));
                                
                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            responseFieldMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
            return;
        } else if (exportType.equals(PDF_VALUE)) {
            String tableData = APPL_PDF_HTML_START;
            String tableRow = '';

            // looping through the parties and crafting the pdf table from the application data
            for (clcommon__party__c objParty : objPartyList) {
                tableRow = PDF_HTML_TR_START;
                tableRow += createPDFTableRow(objParty.genesis__Application__r.Name)
                                + createPDFTableRow(objParty.genesis__Application__r.genesis__Loan_Amount__c)
                                + createPDFTableRow(String.valueOf(objParty.genesis__Application__r.genesis__Account__r.Name))
                                + createPDFTableRow(objParty.genesis__Application__r.Crop_Year__c)
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.genesis__Credit_Rating__r.Name))
                                + createPDFTableRow(objParty.genesis__Application__r.Guarantee__c)
                                + createPDFTableRow(objParty.genesis__Application__r.genesis__Status__c)
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Internal_Reference_Code__c ))
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Growmark_Unique_Identifier__c))
                                + createPDFTableRow(PortalReportsHelper.getformatedDate(objParty.genesis__Application__r.CreatedDate))
                                + createPDFTableRow(PortalReportsHelper.getformatedDate(objParty.genesis__Application__r.Submitted_to_CFA__c));
                
                tableRow += PDF_HTML_TR_END;
                tableData += tableRow;
            }
            tableData += PDF_HTML_END;

            // converting html string to pdf blob and returning
            responseFieldMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
            return;
        }
    }

    
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param partyIdList 
    * @param exportType 
    * @param shouldExportAll 
    **/
    private void exportLoans(Set<Id> partyIdList, String exportType, Boolean shouldExportAll) {

        List<clcommon__party__c> objPartyList;
        Id loggedInAccountId = getUserAccountId();

        if (shouldExportAll) {
            objPartyList = [SELECT Id, 
                                    genesis__Application__r.genesis__Loan_Number__c, 
                                    genesis__Application__r.genesis__Loan_Amount__c, 
                                    genesis__Application__r.genesis__Maturity_Date__c, 
                                    genesis__Application__r.genesis__Account__r.Name, 
                                    genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                    genesis__Application__r.Crop_Year__c, 
                                    genesis__Application__r.Internal_Reference_Code__c, 
                                    genesis__Application__r.Growmark_Unique_Identifier__c,
                                    genesis__Application__r.Guarantee__c, 
                                    genesis__Application__r.Certified_Lenders_Signature__r.Name, 
                                    genesis__Application__r.Sales_Agent__r.Name,
                                    genesis__Application__r.Dealer_Name__r.CIF_Number__c
                            FROM clcommon__party__c 
                            WHERE clcommon__Account__r.Id = :loggedInAccountId
                            AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                            AND genesis__Application__r.genesis__Status__c IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                :PortalConstants.CLOSED_APPLICATION_STATUS,
                                                                                :PortalConstants.APPROVED_APPLICATION_STATUS)];
        } else {
            objPartyList = [SELECT Id, 
                                    genesis__Application__r.genesis__Loan_Number__c, 
                                    genesis__Application__r.genesis__Loan_Amount__c, 
                                    genesis__Application__r.genesis__Maturity_Date__c, 
                                    genesis__Application__r.genesis__Account__r.Name, 
                                    genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                    genesis__Application__r.Crop_Year__c, 
                                    genesis__Application__r.Internal_Reference_Code__c,
                                    genesis__Application__r.Growmark_Unique_Identifier__c,
                                    genesis__Application__r.Guarantee__c, 
                                    genesis__Application__r.Certified_Lenders_Signature__r.Name, 
                                    genesis__Application__r.Sales_Agent__r.Name,
                                    genesis__Application__r.Dealer_Name__r.CIF_Number__c
                            FROM clcommon__party__c 
                            WHERE Id IN :partyIdList
                            AND clcommon__Account__r.Id = :loggedInAccountId
                            AND genesis__Application__r.Dealer_Name__c = :getLoggedInUserDealerId()
                            AND genesis__Application__r.genesis__Status__c IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                :PortalConstants.CLOSED_APPLICATION_STATUS,
                                                                                :PortalConstants.APPROVED_APPLICATION_STATUS)];
        }

        if (objPartyList.size() == 0) {
            throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
        }

        if (exportType.equals(CSV_VALUE)) {
            String tableData = LOAN_CSV_TABLE_HEADING;
            String tableRow = '';

            // looping through the parties and crafting the csv table from the application data
            for (clcommon__party__c objParty : objPartyList) {
                tableRow = createCSVTableRow(objParty.genesis__Application__r.Crop_Year__c)
                                + createCSVTableRow(objParty.genesis__Application__r.genesis__Loan_Number__c)
                                + createCSVTableRow(PortalReportsHelper.getformatedDate(objParty.genesis__Application__r.genesis__Maturity_Date__c))
                                + createCSVTableRow(objParty.genesis__Application__r.genesis__Loan_Amount__c)
                                + createCSVTableRow(objParty.genesis__Application__r.genesis__Account__r.Name)
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.genesis__Credit_Rating__r.Name))
                                + createCSVTableRow(objParty.genesis__Application__r.Guarantee__c)
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Internal_Reference_Code__c))
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Growmark_Unique_Identifier__c))
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Certified_Lenders_Signature__r.Name))
                                + createCSVTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Sales_Agent__r.Name));
                
                
                tableData += tableRow.removeEnd(COMMA_STRING) + '\n';
            }

            // converting comma-separated string to blob and returning
            responseFieldMap.put(CSV_VALUE, EncodingUtil.base64Encode(Blob.valueOf(tableData)));
            return;
        } else if (exportType.equals(PDF_VALUE)) {
            String tableData = LOAN_PDF_HTML_START;
            String tableRow = '';

            // looping through the parties and crafting the pdf table from the application data
            for (clcommon__party__c objParty : objPartyList) {
                tableRow = PDF_HTML_TR_START;
                tableRow += createPDFTableRow(objParty.genesis__Application__r.Crop_Year__c)
                                + createPDFTableRow(objParty.genesis__Application__r.genesis__Loan_Number__c)
                                + createPDFTableRow(PortalReportsHelper.getformatedDate(objParty.genesis__Application__r.genesis__Maturity_Date__c))
                                + createPDFTableRow(objParty.genesis__Application__r.genesis__Loan_Amount__c)
                                + createPDFTableRow(objParty.genesis__Application__r.genesis__Account__r.Name)
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.genesis__Credit_Rating__r.Name))
                                + createPDFTableRow(objParty.genesis__Application__r.Guarantee__c)
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Internal_Reference_Code__c))
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Growmark_Unique_Identifier__c))
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Certified_Lenders_Signature__r.Name))
                                + createPDFTableRow(PortalReportsHelper.getString(objParty.genesis__Application__r.Sales_Agent__r.Name));
                
                tableRow += PDF_HTML_TR_END;
                tableData += tableRow;
            }
            tableData += PDF_HTML_END;


            // converting html string to pdf blob and returning
            responseFieldMap.put(PDF_VALUE, EncodingUtil.base64Encode(Blob.toPdf(tableData)));
            return;
        }
    }
            
   
    /**
    * @description 
    * @author Rahul Gupta | 18-04-2022 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                            String[] disclosureNames,
                                            Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            
            PortalReportsHelper.exportAndDataTypeMissingThrowException(request);
            exportType = String.valueOf(request.get(KEY_EXPORT_TYPE));
            dataType = String.valueOf(request.get(KEY_DATA_TYPE));

            // exporting all data if no application data is provided
            if (String.isBlank((String) request.get(KEY_APPLICATIONS))) {
                if (dataType.equals(APPLICATION_VALUE)) {
                    exportApplications(null, exportType, true);
                } else if (dataType.equals(LOAN_VALUE)) {
                    exportLoans(null, exportType, true);
                }
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
                response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                response.status = clcommon.Constants.SUCCESS;

                return response;
            }

            applicationDetails = String.valueOf(request.get(KEY_APPLICATIONS));

            List<Object> applicationList = (List<Object>) JSON.deserializeUntyped(applicationDetails);

            PortalReportsHelper.checkAndThrowExceptionIfListEmpty(applicationList);
            Set<Id> partyIdList = new Set<Id>();
            for (Object partyId : applicationList) {
                partyIdList.add((Id) partyId);
            }

            
            if (dataType.equals(APPLICATION_VALUE)) {
                exportApplications(partyIdList, exportType, false);
            } else if (dataType.equals(LOAN_VALUE)) {
                exportLoans(partyIdList, exportType, false);
            }
            
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PORTAL_GROWMARK_EXPORT_API);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PORTAL_GROWMARK_EXPORT_API);
        }
        return response;
    }
}