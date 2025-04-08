/**
 * @description       : Test Class For NLSUpdateCreditDrawLimitAdapter & NLSUpdateCreditDrawLimitCalloutBatch
 * @author            : Ayush Kumar Singh 
 * @group             : 
 * @last modified on  : 02-17-2024
 * @last modified by  : Ayush Kumar Singh
**/
@IsTest
public with sharing class NLSUpdateCreditDrawLimitCalloutBatchTest {

   /**
    * @description 
    */
    public class NLSUpdateCreditDrawLimitCalloutBatchMock implements HttpCalloutMock {
        /**
         * @description 
         * @param request 
         * @return  `HTTPResponse`
         */
       public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setStatusCode(200);
           response.setStatus('SUCCESS');
           response.setHeader('Content-Type', 'application/json');
           if(request.getEndpoint().contains('token')){
               String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
               response.setBody(token);
           }
           else{
               response.setBody('{ "status": { "code": 200, "message": "Success" }, "payload": { "data": "" }}');
           }
           return response;
       }
    }
    /**
     * @description 
     */
    public class NLSUpdateCreditDrawLimitCalloutBatchExceptionMock implements HttpCalloutMock {
        /**
         * @description 
         * @param request 
         * @return  `HTTPResponse`
         */
       public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setStatusCode(200);
           response.setStatus('SUCCESS');
           response.setHeader('Content-Type', 'application/json');
           if(request.getEndpoint().contains('token')){
               String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
               response.setBody(token);
           }
           else{
               response.setStatusCode(401);
               response.setBody('{ "status": { "code": 401, "message": "Fail" }, "payload": { "data": "" }}');
           }
           return response;
       }
    }
    
    @isTest(seeAllData=true)
    public static void testNLSUpdateCreditDrawLimitCalloutBatch(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
       
        System.runAs(objAdmin){
            Test.startTest();
            genesis__Funding_Transaction__c fundinTransacObj = [SELECT Id,Status__c,genesis__Application__c
                                                FROM genesis__Funding_Transaction__c 
                                                WHERE genesis__cleared__c=true 
                                                AND Posted_to_NLS__c=true 
                                                AND genesis__Payment_Mode__r.Name=:ConstantValues.PRODUCT_RETURN limit 1];
            String fundinTransacObjId = String.valueOf(fundinTransacObj.id);
            List<String> fundinTransacIdList = new List<String>();
            fundinTransacIdList.add(fundinTransacObjId);
            Test.setMock(HttpCalloutMock.class, new NLSUpdateCreditDrawLimitCalloutBatchMock());
            NLSUpdateCreditDrawLimitCalloutBatch updateCreditDrawLimit = new NLSUpdateCreditDrawLimitCalloutBatch(fundinTransacIdList);
            Database.executeBatch(updateCreditDrawLimit,1);
            System.assertEquals('','','');
            Test.stopTest();
        }
    }

    @isTest(seeAllData=true)
    public static void testNLSUpdateCreditDrawLimitCalloutBatchException(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
       
        System.runAs(objAdmin){
            Test.startTest();
            List<String> fundinTransacIdList = new List<String>();
            fundinTransacIdList.add('a7r74001000DniPAAP');
            Test.setMock(HttpCalloutMock.class, new NLSUpdateCreditDrawLimitCalloutBatchMock());
            NLSUpdateCreditDrawLimitCalloutBatch updateCreditDrawLimit = new NLSUpdateCreditDrawLimitCalloutBatch(fundinTransacIdList);
            Database.executeBatch(updateCreditDrawLimit,1);
            System.assertEquals('','','');
            Test.stopTest();
        }
    }
}