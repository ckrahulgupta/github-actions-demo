/**
 * @description       : Class to Generate Mock Response
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
global without sharing class FICOMockResponseGenerator implements HttpCalloutMock{
    /**
    * @description Generates Mock Response
    * @author  Pritam Roy | 03-04-2024 
    * @param req 
    * @return HttpResponse 
    **/
    global static HttpResponse respond(HttpRequest req){
        HttpResponse response = new HttpResponse();
        StaticResource ficoResponse = new StaticResource();
        if(StaticResource.SObjectType.getDescribe().isAccessible()){
            ficoResponse = [SELECT Id, Body FROM StaticResource WHERE Name ='FICOMockResponse'];
        }
        String ficoResponseBody = ficoResponse.body.toString();
        response.setBody(ficoResponseBody);
        response.setHeader('Content-Type', 'text/xml;charset=utf-8');
        response.setStatusCode(200);
        return response;
    }
}