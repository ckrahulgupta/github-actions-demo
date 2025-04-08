/**
 * @description       : 
 * @author            : Rahul Gorai
 * @group             : 
 * @last modified on  : 02-11-2025
 * @last modified by  : Rahul Gorai
**/
global with sharing class PowerBiReportAdapter extends intframework.BaseIntegrationAdapter{
    String workspaceId;
    String reportId;
    public static final String DEALER_EMBEDDED = 'Dealer Embedded';
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String REPORTS = '/reports/';
    public static final String BASEURL='https://api.powerbi.com/v1.0/myorg/groups/';
    public override String generateRequestBody(Map<String, Object> requestMapping){
        System.debug('Request mapping==> ' + requestMapping);
        String requestBody;
        List<Map<String, Object>> dealerEmbeddedList;
        if(requestMapping.get(DEALER_EMBEDDED) != null){
            dealerEmbeddedList = (List<Map<String, Object>>)requestMapping.get(DEALER_EMBEDDED);
        }
        workspaceId=(String)dealerEmbeddedList[0].get('WorkspaceId');
        reportId=(String)dealerEmbeddedList[0].get('ReportId');
        return requestBody; 
    }

    //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        String endpointUrl;
        String accessToken;
        Http http = new Http();
        HttpResponse httpResponse;
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();

        try{
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessToken = PowerBiEmbedManager.getPowerBiAccessTokenCallout();
                if(accessToken != null){
                    break;
                }
            }
            System.debug('Access token ---> ' + accessToken);
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessToken);
            httprequest.setHeader(ConstantValues.AUTHORIZATION, objAccessTokenNLSWrapper.token_type 
                                    + ' ' + objAccessTokenNLSWrapper.access_token );
            endpointUrl=BASEURL+workspaceId+REPORTS+reportId;
            httprequest.setEndpoint(endpointUrl);
            httpResponse = http.send(httpRequest);
            return httpResponse;
        }catch(Exception objException){
            return null;
        }

    }



}