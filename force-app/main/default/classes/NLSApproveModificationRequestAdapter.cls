/**
 * @description       : Adapter class for Approve Modification Request
 * @author            : Simran
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : Simran
**/
global with sharing class NLSApproveModificationRequestAdapter extends intframework.BaseIntegrationAdapter{

    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String FAILED_TO_FETCH = 'Failed to fetch data.';
    private static final String KEY_GET_APP_NOTE_FIELD = 'getAppNoteField';
    private static final String REQUEST_BODY = ' - Request Body';
    private static final String RESPONSE_BODY = ' - Response Body';
    private static final String LOAN = ' - Loan Number : ';
    private static final String LOAN_NUMBER ='loanNumber';
    private static final String APP_NOTE_ID ='applicationNoteId';
    List<Map<String, Object>> appNoteList = new List<Map<String, Object>>();
    String requestBody;
    String appLoanNumber;
    String applicationNote;
 
    public override String generateRequestBody(Map<String, Object> requestMap){
        appNoteList = (List<Map<String, Object>>)requestMap.get(KEY_GET_APP_NOTE_FIELD);
        try{
            if(requestMap.get(KEY_GET_APP_NOTE_FIELD)==null){  
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            for(Map<String, Object> appNote : appNoteList){
                appLoanNumber=String.valueOf(appNote.get(LOAN_NUMBER));
                applicationNote=String.valueOf(appNote.get(APP_NOTE_ID));
            }  
            requestBody = RequestBodyGeneratorHelper.generateXMLBodyForModificationRequest(appNoteList);
            return requestBody;
        }
        catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, NLSApproveModificationRequestAdapter.class.getName());    
            return null;
        }     
    }
 
    public override System.HttpResponse sendRequest(System.HttpRequest request){
        HttpResponse response = new HttpResponse();
        String accessToken;
        Http http = new Http();
        AccessTokenNLSWrapper accessTokenObj = new AccessTokenNLSWrapper();
        try{
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessToken = AccessTokenGenerator.getAccessToken();
                if(accessToken != null){
                    break;
                }
            }
            if(accessToken == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
            accessTokenObj = AccessTokenNLSWrapper.parse(accessToken);
            request.setHeader(ConstantValues.AUTHORIZATION, 
                            accessTokenObj.token_type 
                            + ' ' + 
                            accessTokenObj.access_token);
 
            response = http.send(request);
            AccessTokenGenerator.revokeAccessToken(accessTokenObj.access_token);
            genesis__Application_Note__c appNoteObj = [SELECT Id,
                                                            Status__c
                                                        FROM genesis__Application_Note__c
                                                        WHERE Id=:applicationNote]; 
            if(appNoteObj==null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            } 
            LoggingUtility.saveRequestLogging(NLSApproveModificationRequestAdapter.class.getName()+ LOAN +appLoanNumber+ REQUEST_BODY, REQUEST_BODY+request.getBody());
            LoggingUtility.saveResponseLogging(NLSApproveModificationRequestAdapter.class.getName()+ LOAN +appLoanNumber+ RESPONSE_BODY, RESPONSE_BODY+response.getBody());
            if(response.getStatusCode() != 200){
                appNoteObj.Status__c=ConstantValues.APPLICATION_NOTE_FAILED_STATUS;
                Database.update(appNoteObj,true);
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            if(response.getStatusCode() == 200){
                appNoteObj.Status__c=ConstantValues.APPLICATION_NOTE_APPROVE_STATUS;
                Database.update(appNoteObj,true);
            }
            return response;
        }
        catch(Exception objException){
            AccessTokenGenerator.revokeAccessToken(accessTokenObj.access_token);
            LoggingUtility.saveExceptionLogging(objException, NLSApproveModificationRequestAdapter.class.getName());
            return null;
        }   
    }
    
}