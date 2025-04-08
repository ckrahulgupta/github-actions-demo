/**
 * @description       : This class is used to generate the access token for docusign callout
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 05-10-2024
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class DocuSignCreateAccessToken{
    private static final String SCOPE = 'signature impersonation';
    private static final String KEY_SCOPE = 'scope';
    private static final String CLASS_NAME = 'DocuSignCreateAccessToken';
    private static final String ALGO_NAME = 'AES128';
    private static final String DUMMY_TOKEN = 'dummyToken';

    /**
     * @description This method is used to generate the access token for In-Person Docusign
     * @return  `string`
     * @exception 
     */
    public static string getAccessToken() {
        try{
            CFA_Configuration__c credentialParameters =  CFA_Configuration__c.getOrgDefaults();
            Auth.JWT jwt =  new  Auth.JWT();
            Map<String,  Object> claims = new Map<String,  Object>();
            Auth.JWS jws;
            String token; 
            String accessToken;
            Auth.JWTBearerTokenExchange bearer; 
            

            checkParameter(credentialParameters);
            
            Blob userId = Crypto.decryptWithManagedIV(ALGO_NAME, EncodingUtil.base64Decode(credentialParameters.Docusign_Decrypt_Key__c),EncodingUtil.base64Decode(credentialParameters.Docusign_User_Id__c));
            Blob issuer = Crypto.decryptWithManagedIV(ALGO_NAME, EncodingUtil.base64Decode(credentialParameters.Docusign_Decrypt_Key__c),EncodingUtil.base64Decode(credentialParameters.Docusign_Integration_Key__c	));

            jwt.setSub(userId.toString());
            jwt.setAud(credentialParameters.Docusign_Audience__c);
            jwt.setIss(issuer.toString());

            claims =  new  Map<String,  Object>();
            claims.put(KEY_SCOPE,  SCOPE);
        
            jwt.setAdditionalClaims(claims);
            jws =  new  Auth.JWS(jwt, ConstantValues.CERT_NAME);
            token = jws.getCompactSerialization();

            bearer =  new  Auth.JWTBearerTokenExchange(credentialParameters.Docusign_Token_Endpoint__c, jws);
            if(Test.isRunningTest()){
                accessToken = DUMMY_TOKEN;
            }
            else{
                accessToken = bearer.getAccessToken();
            }
            if(accessToken == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
        
            return accessToken;
        }
        catch(Exception objException){
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return objException.getMessage();
        }
    }
    /**
     * @description Checking Required Parameter
     * @param credentialParameters 
     * @exception 
     */
    private static void checkParameter(CFA_Configuration__c credentialParameters){
        if(credentialParameters == null
                    || credentialParameters.Docusign_User_Id__c == null 
                    || credentialParameters.Docusign_Audience__c == null 
                    || credentialParameters.Docusign_Token_Endpoint__c == null 
                    || credentialParameters.Docusign_Integration_Key__c == null
                    || credentialParameters.Docusign_Decrypt_Key__c == null) {
                throw new CustomException(ConstantValues.CREDENTIAL_ERROR);
            }
    }

}