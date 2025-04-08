/**
 * @description       : Book To Core Adapter
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-17-2024
 * @last modified by  : Kabir Pramanik
**/
 
global with sharing class NLSBookToCoreImportAdapter extends intframework.BaseIntegrationAdapter{
    
    String requestBody;
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String NLS_XML_IMPORT_ADAPTER = 'NLSBookToCoreImportAdapter';
    private static final String ATTACHMENT = 'Response from NLS - Book To Core';
    private static final String KEY_COOP_TYPE = 'coopType';
    private static final String KEY_APPLICATION = 'Application';
    private static final String KEY_LOAN_NUM = 'LoanNumber';
    private static final String ID = 'Id';

    String coopType;
    String appId;
    String loanNumber;

        //This method is responsible for generating the request body through RequestBodyGeneratorHelper class.
    public override String generateRequestBody(Map<String, Object> requestMapping){
        System.debug('---------> requestMapping ' + requestMapping);
        List<Map<String, Object>> applicationResponses = (List<Map<String, Object>>)requestMapping.get(KEY_APPLICATION);
        appId = String.valueOf(applicationResponses[0].get(ID));
        loanNumber = String.valueOf(applicationResponses[0].get(KEY_LOAN_NUM));

        RequestBodyGeneratorHelper requestBodyGenerator = new RequestBodyGeneratorHelper();
        coopType = (String) requestMapping.get(KEY_COOP_TYPE);
        if(coopType == PortalConstants.GROWMARK_COOP_TYPE){
            requestBody = requestBodyGenerator.bookToCoreXMLRequestBodyForGrowmark(requestMapping);
        }else{
            requestBody = requestBodyGenerator.bookToCoreXMLRequestbody(requestMapping);
        }
        return requestBody;
    }
    
    //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request and new data types
        String accessToken;
        Http http = new Http();
        HttpResponse httpResponse;
        Blob objBlob;
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        //try{
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessToken = AccessTokenGenerator.getAccessToken();
                if(accessToken != null){
                	break;
            	}
            }
            if(accessToken == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessToken);
            httpRequest.setHeader(ConstantValues.AUTHORIZATION, objAccessTokenNLSWrapper.token_type 
                                    + ' ' + objAccessTokenNLSWrapper.access_token );
            httpResponse = http.send(httpRequest);

            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);

            if (!Schema.sObjectType.clcommon__Log__c.isCreateable()) {
                throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS);
            }
            Database.insert(new clcommon__Log__c(Name = 'Request Body - Book To Core' ,
                    clcommon__Message__c = 'Request Body - Book To Core' 
                    + httpRequest.getBody(),
                    clcommon__Time__c = System.Now()), false); 
            objBlob = Blob.valueOf(httpRequest.getBody());

            //insert book to core request in application
            Attachment objAttachment = new Attachment();
            objAttachment.Body = objBlob;
            objAttachment.ParentId = appId;
            objAttachment.Name = 'BOOK TO CORE - REQUEST - ' + loanNumber + '.xml';
            Database.insert(objAttachment, false);

            Database.insert(new clcommon__Log__c(Name = 'Response Body - Book To Core' ,
                    clcommon__Message__c = 'Response Body - Book To Core'
                    + httpResponse.getBody(),
                    clcommon__Time__c = System.Now()), false);
            if(httpResponse.getStatusCode() != 200) {
                Map<String,Object> errorNLSMap = (Map<String,Object>)JSON.deserializeUntyped(httpResponse.getBody());
                List<Object> errorList = (List<Object>)Json.deserializeUntyped(Json.Serialize(errorNLSMap.get('errors')));
                Map<String,Object> errorMap =  (Map<String,Object>)JSON.deserializeUntyped(Json.Serialize(errorList[0]));
                System.debug('ERROR ==== List ----'+errorMap.get('message'));
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION + ' - ' + errorMap.get('message'));
            }
            return httpResponse;
        // }
        // catch (Exception objException) {
        //     Database.insert(new clcommon__Log__c(Name = NLS_XML_IMPORT_ADAPTER ,
        //             clcommon__Message__c = NLS_XML_IMPORT_ADAPTER  
        //             + objException.getStackTraceString()
        //             + objException.getMessage(),
        //             clcommon__Time__c = System.Now()), false);   
        //     return null;
        // }
    }
}