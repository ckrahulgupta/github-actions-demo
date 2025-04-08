/**
 * @description       : Purpose of this class is to fetch the generated conga template document Id
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Tuhin Bhunia
**/

global without sharing class PortalFetchCongaTemplateAPI implements clcommon.PortalCustomRemoteAPI1 {
    // constants specific for this class [start]
    private static final String KEY_APPLICATION_ID = 'applicationId';
    private static final String KEY_FILE_NAME = 'templateName';
    private static final String AGREEMENT_TEMPLATE_VALUE = 'agreementTemplate';
    private static final String WITHDRAWAL_FORM_TEMPLATE_VALUE = 'withdrawalFormTemplate';
    private static final String CUSTOMIZED_FORM_TEMPLATE_VALUE = 'customizedFormTemplate';
    
    private static final String FETCH_CONTENT_VERISON_SOQL_START = 'SELECT Id, Title FROM ContentVersion WHERE contentDocumentId IN (';
    private static final String FETCH_CONTENT_VERISON_SOQL_END = ' AND Title LIKE';
    private static final String FETCH_CONTENT_VERISON_SOQL_LIMIT = ' LIMIT 1';
    private static final String SINGLE_QUOTE_STRING = '\'';
    private static final String COMMA_STRING = ', ';
    private static final String CLOSING_FIRST_BRACKET_STRING = ')';
    private static final String PORTAL_FETCH_CONGA_TEMPLATE_API = 'PortalFetchCongaTemplateAPI';
    // constants specific for this class [end]
    
    String applicationId = '';
    String templateName = '';
   
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
            
    /**
     * @description : This method takes and validates the portal request and generates conga template document Id.
     * @author Rahul Gupta | 26-04-2022 
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();

        List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
        List<ContentVersion> objContentVersionList =  new List<ContentVersion>();

        String fileName = '';
        String noDocumentCustomExceptionMessage = '';
       
        try {
            if (String.isBlank((String) request.get(KEY_APPLICATION_ID)) || String.isBlank((String) request.get(KEY_FILE_NAME))) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            applicationId = String.valueOf(request.get(KEY_APPLICATION_ID));
            templateName = String.valueOf(request.get(KEY_FILE_NAME));

            
            if (templateName.equals(AGREEMENT_TEMPLATE_VALUE)) {
                fileName = PortalConstants.AGREEMENT_FILE_NAME;
                noDocumentCustomExceptionMessage = PortalConstants.NO_AGREEMENT_FOUND;

            } else if (templateName.equals(CUSTOMIZED_FORM_TEMPLATE_VALUE)) {
                fileName = PortalConstants.CUSTOMIZED_FORM_FILE_NAME;
                noDocumentCustomExceptionMessage = PortalConstants.NO_CUSTOMIZED_FORM_FOUND;

            } else if (templateName.equals(WITHDRAWAL_FORM_TEMPLATE_VALUE)) {
                fileName = PortalConstants.WITHDRAWAL_FORM_FILE_NAME;
                noDocumentCustomExceptionMessage = PortalConstants.NO_WITHDRAWAL_FORM_FOUND;

            } else {
                throw new CustomException(PortalConstants.NO_DOCUMENT_FOUND);
            }

            // validating application Id
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            String contentDocumentIdString = '';
            objContentDocumentLinkList = [SELECT ContentDocumentId 
                                          FROM ContentDocumentLink 
                                          WHERE linkedEntityId = :applicationId];
            
            if (objContentDocumentLinkList.size() > 0) {
                // creating the comma-separated string of all the ids that needs to be queried
                for (ContentDocumentLink objContentDocumentLink : objContentDocumentLinkList) {
                    contentDocumentIdString += SINGLE_QUOTE_STRING 
                                                + objContentDocumentLink.ContentDocumentId 
                                                + SINGLE_QUOTE_STRING 
                                                + COMMA_STRING;
                }
                
                contentDocumentIdString = contentDocumentIdString.removeEnd(COMMA_STRING) + CLOSING_FIRST_BRACKET_STRING;

                // crafting the query for fetching the content versions
                String fetchContentVersionsSOQL = FETCH_CONTENT_VERISON_SOQL_START 
                                                    + contentDocumentIdString 
                                                    + FETCH_CONTENT_VERISON_SOQL_END 
                                                    + SINGLE_QUOTE_STRING 
                                                    + fileName
                                                    + SINGLE_QUOTE_STRING 
                                                    + FETCH_CONTENT_VERISON_SOQL_LIMIT;
                
                objContentVersionList = Database.query(fetchContentVersionsSOQL);

                if (objContentVersionList.size() != 1) {
                    // throw new CustomException(noDocumentCustomExceptionMessage);
                    response.status = clcommon.Constants.PENDING;
                    return response;
                }
            } else {
                // throw new CustomException(noDocumentCustomExceptionMessage);
                response.status = clcommon.Constants.PENDING;
                return response;
            }
        
            for(ContentVersion objContentVersion: objContentVersionList) {
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(objContentVersion));
            }
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 
        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PORTAL_FETCH_CONGA_TEMPLATE_API);
            
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PORTAL_FETCH_CONGA_TEMPLATE_API);
        }
        return response;
    }
}