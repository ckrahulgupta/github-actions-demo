/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Subham Nandi
**/
global with sharing class InPersonDSUpdateRecipientAdapter extends intframework.BaseIntegrationAdapter{
    private static final String KEY_GET_ENVELOPE = 'Envelope';
    private static final String KEY_GET_RECIPIENT = 'Recipient';
    private static final String KEY_DOCUSIGN_ID = 'docuSignId';
    private static final String KEY_AUTH = 'Authorization';
    private static final String KEY_CONTENT_TYPE = 'Content-Type';
    private static final String BEARER = 'Bearer ';
    private static final String KEY_VALUE_CONTENT_TYPE = 'application/json';
    private static final String DUMMY_ACCESS_TOKEN = 'dummyAccessToken';
    private static final String API_VERSION_PLACEHOLDER = '{!apiVersion}';
    private static final String ACC_ID_PLACEHOLDER = '{!accountId}';
    private static final String ENVELOPE_ID_PLACEHOLDER = '{!envelopeId}';
    private static final String SIGNING_TYPE = 'signingMethod';

    List<Map<String,Object>> requestListEnvelope = new List<Map<String,Object>>();
    List<Map<String,Object>> requestListRecipient = new List<Map<String,Object>>();

    /**
    * @description 
    * @author Krishanu Chinya | 06-24-2024 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
        try{
            if(requestMap.get(KEY_GET_ENVELOPE)!=null){    
                requestListEnvelope = (List<Map<String, Object>>)requestMap.get(KEY_GET_ENVELOPE);
                requestListRecipient = (List<Map<String, Object>>)requestMap.get(KEY_GET_RECIPIENT);
                String body = '';
                if(requestMap.get(SIGNING_TYPE)== ConstantValues.IN_PERSON_HYBRID){
                    body = DocusignUtil.createRequestBodyToUpdateEnvelopeForInPersonHybrid(requestListRecipient);
                }else{
                    body = DocusignUtil.createRequestBodyToUpdateEnvelope(requestListRecipient);
                }
                return body;
            }
            else{
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, InPersonDSUpdateRecipientAdapter.class.getName());    
            return null;
        }     
    }

    public override System.HttpResponse sendRequest(System.HttpRequest req){

         try{
            String newEndPoint = '';
            Map<String,Object> objrequestMapEnvelope = requestListEnvelope[0];  
            String accessToken =  DocuSignCreateAccessToken.getAccessToken();

            if(requestListEnvelope.size()==0){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            List<CFA_Configuration__c> docusignParameters = getRequiredParameter();

            req.setHeader(KEY_AUTH, BEARER + accessToken);
            req.setHeader(KEY_CONTENT_TYPE, KEY_VALUE_CONTENT_TYPE);

            // if(objrequestMapEnvelope.get(KEY_DOCUSIGN_ID) == null){
            //     throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            // }
            String endpointURL =req.getEndpoint();
            //newEndPoint = endpointURL.replace(API_VERSION_PLACEHOLDER, docusignParameters[0].Docusign_Api_Version__c );
            //newEndPoint = newEndPoint.replace(ACC_ID_PLACEHOLDER, docusignParameters[0].Docusign_Account_Id__c);
            //newEndPoint = newEndPoint.replace(ENVELOPE_ID_PLACEHOLDER,String.valueof(objrequestMapEnvelope.get(KEY_DOCUSIGN_ID)));
            //req.setEndpoint(newEndPoint);


            Http http = new Http();
            HTTPResponse response = http.send(req);
            if(response.getStatusCode() != 200){          
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            return response;
         }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, InPersonDSUpdateRecipientAdapter.class.getName());    
            return null;
        }
    }

    /**
     * @description Return the required parameter needed for callout.
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