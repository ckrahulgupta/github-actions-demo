/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 05-10-2024
 * @last modified by  : Ayush Kumar Singh
**/
global with sharing class InPersonDSGetURLAdapter extends intframework.BaseIntegrationAdapter{
    private static final String KEY_GET_ENVELOPE = 'Envelope';
    private static final String KEY_GET_RECIPIENT = 'Recipient';
    private static final String KEY_DOCUSIGN_ID = 'docuSignId';
    private static final String KEY_GET_PARTY= 'Party';
    private static final String KEY_URL = 'url';
    private static final String KEY_PARTY_ID = 'ID';
    private static final String KEY_AUTH = 'Authorization';
    private static final String KEY_CONTENT_TYPE = 'Content-Type';
    private static final String BEARER = 'Bearer ';
    private static final String KEY_VALUE_CONTENT_TYPE = 'application/json';
    private static final String API_VERSION_PLACEHOLDER = '{!apiVersion}';
    private static final String ACC_ID_PLACEHOLDER = '{!accountId}';
    private static final String ENVELOPE_ID_PLACEHOLDER = '{!envelopeId}';

    List<Map<String,Object>> requestListEnvelope = new List<Map<String,Object>>();
    List<Map<String,Object>> requestListRecipient = new List<Map<String,Object>>();
    List<Map<String,Object>> requestListParty = new List<Map<String,Object>>();

    public override String generateRequestBody(Map<String, Object> requestMap){
        try{
            List<CFA_Configuration__c> docusignParameters =  getRequiredParameter();
            if(requestMap.get(KEY_GET_ENVELOPE)!=null && requestMap.get(KEY_GET_RECIPIENT) !=null && requestMap.get(KEY_GET_PARTY)!=null){    
                requestListEnvelope = (List<Map<String, Object>>)requestMap.get(KEY_GET_ENVELOPE);
                requestListRecipient = (List<Map<String, Object>>)requestMap.get(KEY_GET_RECIPIENT);
                requestListParty = (List<Map<String,Object>>)requestMap.get(KEY_GET_PARTY); 
                
                Map<String,Object> objrequestMapRecipient = requestListRecipient[0];
                Map<String,Object> requestPartyMap = requestListParty[0];
                String body = DocusignUtil.createRequestBodyToGetUrlForDS(requestPartyMap,docusignParameters,objrequestMapRecipient);
                return body;
                
            }
            else{
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, InPersonDSGetURLAdapter.class.getName());    
        }  
        return null;   
    }

    public override System.HttpResponse sendRequest(System.HttpRequest req){
    try{
        String signingUrl = '';
        String newEndPoint = '';  
        Map<String,Object> objrequestMapEnvelope = requestListEnvelope[0];  
        String accessToken = DocuSignCreateAccessToken.getAccessToken();
            
        List<CFA_Configuration__c> docusignParameters = getRequiredParameter();

        req.setHeader(KEY_AUTH, BEARER + accessToken);
        req.setHeader(KEY_CONTENT_TYPE, KEY_VALUE_CONTENT_TYPE);

//        if(objrequestMapEnvelope.get(KEY_DOCUSIGN_ID) == null){
            //throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
  //      }
       
        String endpointURL =req.getEndpoint();
        //newEndPoint = endpointURL.replace(API_VERSION_PLACEHOLDER , docusignParameters[0].Docusign_Api_Version__c);
        //newEndPoint = newEndPoint.replace(ACC_ID_PLACEHOLDER , docusignParameters[0].Docusign_Account_Id__c);
        //newEndPoint = newEndPoint.replace(ENVELOPE_ID_PLACEHOLDER ,String.valueof(objrequestMapEnvelope.get(KEY_DOCUSIGN_ID)));
        //req.setEndpoint(newEndPoint);
       
        Http http = new Http();
        HTTPResponse response = http.send(req);
        if(response.getStatusCode() == 201){          
            Map<string,Object> responseMap = (Map<string,Object>)JSON.deserializeUntyped(response.getBody());
            signingUrl = (String)responseMap.get(KEY_URL);
            Map<String,Object> objPartyMap = requestListParty[0];
            if(objPartyMap.get(KEY_PARTY_ID) == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            String partyId = (String)objPartyMap.get(KEY_PARTY_ID); 
            updateParty(partyId,responseMap);   
        }
        else{
            throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
        }
        return response;   
    }
    catch (Exception objException) {
        PortalHelper.saveExceptionLog(objException, InPersonDSGetURLAdapter.class.getName());
    }
    return null;
   
  }
  
  /**
   * @description  Update Url in Party
   * @param partyId 
   * @param responseMap 
   * @exception 
   */
  private static void updateParty(String partyId,Map<string,Object> responseMap){
    List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
    if(Schema.sObjectType.clcommon__Party__c.isAccessible()){
            partyList = [SELECT Id,
                        DocuSign_URL__c,
                        DocuSign_Generation_Time__c 
                FROM clcommon__Party__c 
                WHERE id =:partyId limit 1 ];
    }
    if(partyList != null){
        partyList[0].DocuSign_URL__c = (String)responseMap.get(KEY_URL);
        partyList[0].DocuSign_Generation_Time__c = System.now();
        partyList[0].Sent_Url__c =false;
        if(Schema.sObjectType.clcommon__Party__c.isUpdateable()){
            Database.update(partyList,true);
        }
    }
    else{
        throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
    }
  }  

  /**
   * @description Checking Required parameter
   * @return  `CFA_Configuration__c`
   * @exception 
   */
  private static List<CFA_Configuration__c> getRequiredParameter(){
    List<CFA_Configuration__c> docusignParameters;
    if(Schema.sObjectType.CFA_Configuration__c.isAccessible()){
    docusignParameters = [SELECT Docusign_Account_Id__c,
                                    Docusign_Api_Version__c,
                                    Docusign_CFA_Return_Url__c,
                                    Docusign_Landus_Return_Url__c,
                                    Docusign_GMK_Return_Url__c
                                FROM CFA_Configuration__c LIMIT 1];
    }
    if(docusignParameters[0] == null
            || docusignParameters[0].Docusign_Account_Id__c == null
            || docusignParameters[0].Docusign_Api_Version__c == null
            || docusignParameters[0].Docusign_CFA_Return_Url__c  == null
            || docusignParameters[0].Docusign_Landus_Return_Url__c  == null
            || docusignParameters[0].Docusign_GMK_Return_Url__c  == null) {
        throw new CustomException(ConstantValues.CREDENTIAL_ERROR);
    }
    return docusignParameters;
  }
}