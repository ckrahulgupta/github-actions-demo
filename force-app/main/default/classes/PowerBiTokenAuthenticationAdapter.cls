/**
 * @description       : 
 * @author            : Rahul Gorai
 * @group             : 
 * @last modified on  : 02-11-2025
 * @last modified by  : Rahul Gorai
**/
global with sharing class PowerBiTokenAuthenticationAdapter extends intframework.BaseIntegrationAdapter {

    String tentantId; 
    String clientId;
    String clientSecret;
    public static final String CLIENTID = 'ClientID';
    public static final String CLIENTSECRET = 'ClientSecret';
    public static final String TENANTID = 'TenantID';
    public static final String SCOPE='https://analysis.windows.net/powerbi/api/.default';
	public static final String GRANT_TYPE='client_credentials';
    public static final String CLIENT_INFO='1';
    public static final String ENDURL='https://login.microsoftonline.com/';
    public static final String ENDPOINT='/oauth2/v2.0/token';
    public static final String POST='POST';
    public static final String CONTENT_TYPE='Content-Type';
    public static final String URL_ENCODED = 'application/x-www-form-urlencoded';
    public static final String POWER_BI_AUTH_SETTING_MDT = 'PowerBI';
    public static final Integer SUCCESS_CODE = 200;  
    public static final String NOT_SUCCESS = 'NOT SUCCESS';


    
    /**
    * @description 
    * @author Rahul Gorai | 02-06-2025 
    * @param clientId 
    * @param clientsecret 
    * @return String 
    **/
    public String generateRequestForAuthentication(String clientId,String clientsecret){
        
        String requestBody= 'client_id=' + clientId +
                            '&client_info=' + CLIENT_INFO+
                            '&client_secret=' + clientsecret +
                            '&scope=' + SCOPE  +
                            '&grant_type=' + GRANT_TYPE;
        
        return requestBody;

    }
    
    public override String generateRequestBody( Map<String, Object> requestMapping) {
        
        String requestBody;
        List<Map<String, Object>> authSettingList;
        if(requestMapping.get(POWER_BI_AUTH_SETTING_MDT) != null){
            authSettingList = (List<Map<String, Object>>)requestMapping.get(POWER_BI_AUTH_SETTING_MDT);
        }
        try {
        clientId = (String) authSettingList[0].get('ClientID');
        clientSecret = (String) authSettingList[0].get('ClientSecret');
        tentantId=(String) authSettingList[0].get(TENANTID);
        requestBody = generateRequestForAuthentication(clientId,clientSecret);
        return requestBody;
        } catch(Exception objException){
            throw new CustomException('Error generating request body: ' + objException.getMessage());
        }
    }
     //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        String endPointURL;
        HttpResponse  httpResponse;
        try { 
            Http http = new Http();
            endPointURL=ENDURL+tentantId+ENDPOINT;
            httpRequest.setEndpoint(endPointURL);
            httpRequest.setMethod(POST);
            httpRequest.setBody(httpRequest.getBody());
            httpRequest.setHeader(CONTENT_TYPE, URL_ENCODED);
            httpResponse = http.send(httpRequest);
            if(httpResponse.getStatusCode() != SUCCESS_CODE) {
                throw new CustomException(NOT_SUCCESS);
            }
            System.debug('check adaptor resposese'+ httpResponse);
            return httpResponse;
        } catch (Exception objException){
            throw new CustomException('Error sending request: ' + objException.getMessage());
        }
    }
}