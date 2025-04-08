/**
 * @description       : This class authorize and generate/revoke the accesS token.
 * @author            : Arka Jyoti Deb
 * created date       : 13/12/2021
 * @group             : 
 * @last modified on  : 02-22-2024
 * @last modified by  : Ayan Bhowmik
**/

public with sharing class AccessTokenGenerator{
    
    // parameters specific for this class [start]
    public static final String CLASS_NAME = 'AccessTokenGenerator';
    public static final String GRANT_TYPE = 'grant_type=';
    public static final String USER_NAME = '&username=';
    public static final String PASSWORD = '&password=';     
    public static final String SCOPE = '&scope=';  
    public static final String CLIENT_ID = '&client_id=';  
    public static final String CLIENT_SECRET = '&client_secret=';    
    public static final String BASIC = 'Basic ';  
    public static final String TOKEN = 'token=';  
    public static final String TOKEN_TYPE_HINT = '&token_type_hint=';  
    public static final String ACCESS_TOKEN = 'access_token'; 
    public static final Integer SUCCESS_CODE = 200;  
    public static final String GENERATE_TOKEN_ENDPOINT = 'callout:NLSToken/core/connect/token';
    public static final String REVOKE_TOKEN_ENDPOINT = 'callout:NLSToken/core/connect/revocation';
    public static final String CLIENTID_MERGEFIELD = '{!$Credential.UserName}';
    public static final String PASSWORD_MERGEFIELD = '{!$Credential.Password}';

    // parameters specific for this class [end]
      
    /**
    * @description - Purpose of this method is to authorize and generate the access token.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @return String 
    **/
    public static String getAccessToken() {
        
        try{
            Http http = new Http();
            HttpRequest objRequest = new HttpRequest();
            objRequest.setEndpoint(GENERATE_TOKEN_ENDPOINT);
            objRequest.setMethod(ConstantValues.POST_METHOD);
            String payload = GRANT_TYPE
                            + EncodingUtil.urlEncode(ConstantValues.GRANT_TYPE, ConstantValues.ENCODING_SCHEME)
                            + USER_NAME +  EncodingUtil.urlEncode(ConstantValues.USERNAME,ConstantValues.ENCODING_SCHEME)
                            + PASSWORD +  PASSWORD_MERGEFIELD
                            + SCOPE + EncodingUtil.urlEncode(ConstantValues.SCOPE,ConstantValues.ENCODING_SCHEME)
                            + CLIENT_ID + CLIENTID_MERGEFIELD
                            + CLIENT_SECRET + PASSWORD_MERGEFIELD;
            objRequest.setBody(payload);
            objRequest.setHeader(ConstantValues.CONTENT_TYPE, ConstantValues.URL_ENCODED);
            HttpResponse response = http.send(objRequest);
            if(response.getStatusCode() != SUCCESS_CODE) {
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            return response.getBody();
        }catch (Exception objException) {
            //call the centralised class to insert the log
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
    
    /**
    * @description - Purpose of this method is to revoke the access token.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param accessToken 
    **/
    public static void revokeAccessToken(String accessToken) {
        
        try{
            Http http = new Http();
            HttpRequest objRequest = new HttpRequest();
            objRequest.setEndpoint(REVOKE_TOKEN_ENDPOINT);
            objRequest.setMethod(ConstantValues.POST_METHOD);
            objRequest.setHeader(ConstantValues.CONTENT_TYPE, ConstantValues.URL_ENCODED);
            objRequest.setHeader(ConstantValues.AUTHORIZATION, 
                                BASIC + 
                                EncodingUtil.base64Encode(Blob.valueOf(ConstantValues.CLIENT_ID +
                                ':' + 
                                PASSWORD_MERGEFIELD)));
            String payload  =   TOKEN +
                                EncodingUtil.urlEncode(accessToken, ConstantValues.ENCODING_SCHEME) +
                                TOKEN_TYPE_HINT +
                                EncodingUtil.urlEncode(ACCESS_TOKEN,ConstantValues.ENCODING_SCHEME);    
            objRequest.setBody(payload);
            HttpResponse response = http.send(objRequest);
            if(response.getStatusCode() != SUCCESS_CODE) {
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
        }catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.ACCESS_TOKEN_GENERATOR);
        }
    }
}