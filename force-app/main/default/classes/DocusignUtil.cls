/**
 * @description       : utility class for DocuSign
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Krishanu Chinya
**/
public inherited sharing class DocusignUtil{
    private static final String KEY_RECIPIENT_ID = 'recipientId';
    private static final String KEY_COOP_TYPE = 'CoopType';
    private static final String KEY_EMAIL = 'email';
    private static final String KEY_RECIPIENT_NAME = 'recipientName';
   
   /**
    * @description Creating Request Body to get URL From Docusign
    * @param requestPartyMap 
    * @param docusignParameters 
    * @param recipientDataMap 
    * @return  `String`
    * @exception 
    */
    public static String createRequestBodyToGetUrlForDS(Map<String,Object> requestPartyMap,List<CFA_Configuration__c> docusignParameters,Map<String,Object> recipientDataMap){
        String body = '';
        if(requestPartyMap.get(KEY_COOP_TYPE) == ConstantValues.GROWMARK_COOP_TYPE){
            body += '{"returnUrl": "' + docusignParameters[0].Docusign_GMK_Return_Url__c +'",';
        }
        else if(requestPartyMap.get(KEY_COOP_TYPE) == ConstantValues.LANDUS_COOP_TYPE){
            body += '{"returnUrl": "' + docusignParameters[0].Docusign_Landus_Return_Url__c +'",';
        }
        else{
            body += '{"returnUrl": "' + docusignParameters[0].Docusign_CFA_Return_Url__c +'",';
        }
        body += '"authenticationMethod": "none",';
        body += '"email": "' + recipientDataMap.get(KEY_EMAIL)+ '",';
        body += '"userName": "' + recipientDataMap.get(KEY_RECIPIENT_NAME) + '",';
        body += '"clientUserId": "' + recipientDataMap.get(KEY_RECIPIENT_ID) + '"';
        body += '}';

        return body;
    }
    /**
     * @description Create Request Body to update status of the envelope
     * @return  `String`
     */
    public static String createRequestBodyToUpdateEnvelopeStatus(){
        String body = '{"status": "sent"}';
        return body;
    }
    
    /**
     * @description Create Request Body To Update Envelope for Docusign
     * @param requestListRecipient 
     * @return  `String`
     * @exception 
     */
    public static String createRequestBodyToUpdateEnvelope( List<Map<String,Object>> requestListRecipient){
        String body = '{"signers": [';
        for(Integer signerCount=0;signerCount<requestListRecipient.size();signerCount++){
            Map<String,Object> recipientDataMap = requestListRecipient[signerCount];
            if(!recipientDataMap.keySet().contains(KEY_RECIPIENT_ID)){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            Integer recipientId = signerCount+1;
            body +=   '{"recipientId": "'+String.valueOf(recipientId) +'",';
            body += '"clientUserId": "' + recipientDataMap.get(KEY_RECIPIENT_ID) + '"}';
            if(signerCount!=requestListRecipient.size()-1){
                body+=',';
            }
        }
        body += ']}'; 
        return body;
    }

    /**
    * @description : creates request body when signing method is in person hybrid
    * @author Krishanu Chinya | 06-24-2024 
    * @param requestListRecipient 
    * @return String 
    **/
    public static String createRequestBodyToUpdateEnvelopeForInPersonHybrid( List<Map<String,Object>> requestListRecipient){
        String body = '{"signers": [';
        for(Integer signerCount=0;signerCount<requestListRecipient.size();signerCount++){
            Map<String,Object> recipientDataMap = requestListRecipient[signerCount];
            if(!recipientDataMap.keySet().contains(KEY_RECIPIENT_ID)){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            Integer recipientId = signerCount+1;
            if(signerCount==0){
                body +=   '{"recipientId": "'+String.valueOf(recipientId) +'",';
                body += '"clientUserId": "' + recipientDataMap.get(KEY_RECIPIENT_ID) + '"}';
                body+=',';
            }
        }
        body += ']}'; 
        return body;
    }
    
}