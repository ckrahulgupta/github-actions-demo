/**
 * @description       : Calls Request Geneerator to Generate the request, sets the headers and then Calls FICO.
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Ayush Kumar Singh
**/


global with sharing class FICOAdapter extends intframework.BaseIntegrationAdapter{
    //Constant values specific to this class starts
    String applicationId = ConstantValues.EMPTY_STRING;
    String contentLength = 'Content-Length';
    String soapAction = 'SOAPAction';
    private static final String PARTY_INFO = 'PartyInfo';
    private static final String APP_ID = 'ApplicationId';

    //Constant values specific to this class ends

    /**
    * @description : Create FICO Request Body
    * @author  Pritam Roy | 03-06-2024 
    * @param req 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> req){
        try {
            List<Map<String,Object>> requestList = (List<Map<String, Object>>)req.get(PARTY_INFO);
            Map<String,Object> requestMap = requestList[0];
            applicationId = String.valueOf(requestMap.get(APP_ID));
            if(String.isBlank(applicationId)){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            String requestForFICO = FICORequestGeneratorHelper.generateFICORequestBody(req);
            return requestForFICO;
        } 
        catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, FICOAdapter.class.getName());
        }
        return null;
    }
    
    /**
    * @description : Parse the FICO Request
    * @author  Pritam Roy | 03-06-2024 
    * @param httpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request
        Http http = new Http();
        HttpResponse httpResponse;
        try {
            //Attaching the header with the request to make the calluot
            httpRequest.setHeader(contentLength,ConstantValues.HEADER_CONTENT_LENGHT);
            httpRequest.setHeader(soapAction, ConstantValues.HEADER_SOAP_ACTION);
            //sending the request body along with the header to the 3rd party and fetching the response in httpResponse
            httpResponse = http.send(httpRequest);
            //Calling the credit bureau parser
            if(httpResponse.getBody() != null){
                FICOCreditBureauParser.createCreditBureauReport(httpResponse.getBody(), applicationId);
            }
            return httpResponse;
            
        } catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, FICOAdapter.class.getName());
        }
        return null;
    }
}