/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Subham Nandi
**/
global with sharing class InPersonDSUpdateStatusAdapter extends intframework.BaseIntegrationAdapter {
    private static final String KEY_GET_ENVELOPE = 'Envelope';
    List<Map<String,Object>> requestListEnvelope = new List<Map<String,Object>>();
    private static final String KEY_DOCUSIGN_ID = 'docuSignId';
    private static final String KEY_AUTH = 'Authorization';
    private static final String KEY_CONTENT_TYPE = 'Content-Type';
    private static final String BEARER = 'Bearer ';
    private static final String DUMMY_TOKEN = 'dummyToken';
    private static final String KEY_VALUE_CONTENT_TYPE = 'application/json';
    private static final String API_VERSION_PLACEHOLDER = '{!apiVersion}';
    private static final String ACC_ID_PLACEHOLDER = '{!accountId}';
    private static final String ENVELOPE_ID_PLACEHOLDER = '{!envelopeId}';
    private static final String DOCUSIGN_CRED_PARAMS = 'Docusign Parameters';

    public override String generateRequestBody(Map<String, Object> requestMap){

        try{
            if(requestMap.get(KEY_GET_ENVELOPE)!=null){    
                requestListEnvelope = (List<Map<String, Object>>)requestMap.get(KEY_GET_ENVELOPE);
                String body = DocusignUtil.createRequestBodyToUpdateEnvelopeStatus();
                return body;
            }
            else{
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, InPersonDSUpdateStatusAdapter.class.getName());    
            return null;
        }     
    }

    public override System.HttpResponse sendRequest(System.HttpRequest req){
        try{
            String newEndPoint = '';
            String endpointURL;
            Http http = new Http();
            HTTPResponse response;
            if(requestListEnvelope.size()==0){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }

            Map<String,Object> objMapEnvelope = requestListEnvelope[0];
            String accessToken =  DocuSignCreateAccessToken.getAccessToken();
            String token = BEARER + accessToken;
            
            List<CFA_Configuration__c> docusignParameters = getRequiredParameter();
            req.setHeader(KEY_AUTH,token);
            req.setHeader(KEY_CONTENT_TYPE, KEY_VALUE_CONTENT_TYPE);
            
            // if(objMapEnvelope.get(KEY_DOCUSIGN_ID)== null){
            //     throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            // }
        
            endpointURL =req.getEndpoint();
            // newEndPoint = endpointURL.replace(API_VERSION_PLACEHOLDER, docusignParameters[0].Docusign_Api_Version__c);
            // newEndPoint = newEndPoint.replace(ACC_ID_PLACEHOLDER, docusignParameters[0].Docusign_Account_Id__c);
            // newEndPoint = newEndPoint.replace(ENVELOPE_ID_PLACEHOLDER ,String.valueof(objMapEnvelope.get(KEY_DOCUSIGN_ID)));
            // req.setEndpoint(newEndPoint);
        
            
            response = http.send(req);
            if(response.getStatusCode() != 200){          
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            return response;
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, InPersonDSUpdateStatusAdapter.class.getName());    
            return null;
        }
    }

    /**
     * @description check the required parameter needed for callout
     * @return  `CFA_Configuration__c`
     * @exception 
     */
    private static List<CFA_Configuration__c> getRequiredParameter(){
        List<CFA_Configuration__c> docusignParameters;
        if(Schema.sObjectType.CFA_Configuration__c.isAccessible()){
        docusignParameters = [SELECT Docusign_Account_Id__c,
                                        Docusign_Api_Version__c
                                    FROM CFA_Configuration__c LIMIT 1];
        }
        if(docusignParameters == null
                || docusignParameters[0].Docusign_Account_Id__c == null
                || docusignParameters[0].Docusign_Api_Version__c == null) {
            throw new CustomException(ConstantValues.CREDENTIAL_ERROR);
        }
        return docusignParameters;
    }
}