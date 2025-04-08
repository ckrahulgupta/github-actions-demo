/**
 * @description       : This is the test class for NLSModifyFieldCallout
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-15-2024
 * @last modified by  : Tuhin Bhunia
**/
@isTest
public with sharing class NLSModifyFieldCalloutTest {
 @TestSetup
 static void setUp(){
    intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
    intframework__Integration_API_Type__c getModifyFieldAPIType = IntegrationTestInitHelper.getIntegrationAPIType(family.id,'Modify Field Api Type');
    intframework__Integration_Provider__c getModifyFieldProvider = IntegrationTestInitHelper.getIntegrationProvider(family.id,'Modify Field Provider');
    intframework__Integration_Configuration__c getModifyFieldConfiguration = IntegrationTestInitHelper.getIntegrationConfiguration(getModifyFieldProvider.id,'Modify Field Configuration','NLS');
    intframework__Integration_API_Configuration__c	getModifyFieldAPIConfiguration = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
        family.id,
        getModifyFieldAPIType.id,
        getModifyFieldProvider.id,
        getModifyFieldConfiguration.id,
        false,
        'NLSModifyFieldAdapter',
        'POST',
        'NLS',
        '/nls/xml-import',
        '{ "thirdPartySystem": { "name": "Get Field", "filters": [ {"objectAPI": "genesis__Applications__c", "objectAlias": "getAppField","fields": [{ "externalField": "loanNumber", "fieldAPI": "genesis__Loan_Number__c"},{"externalField": "creditTotalDrawLimit", "fieldAPI": "Credit_Total_Draw_Limit__c"}],"whereClause": "Id IN :appList"}]}}',
        'application/json',
        1);

     genesis__Applications__c newApplication = TestClassHelper.createApplication();
     newApplication.Reserved_Amount__c  = 500;
     Database.upsert(newApplication);
 }

 /**
  * @description : Mock http callout class for test methods
  */
 public class NLSModifyFieldHttpCalloutMock implements HttpCalloutMock {

    /**
     * @description : Mock http response method
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
  * @description : Mock http callout class for test methods
  */
 public class NLSModifyFieldHttpCalloutMock1 implements HttpCalloutMock {

    /**
     * @description : Mock Response class for test methods.
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
 @isTest
 public static void testModifyField(){
    Test.startTest();
    genesis__Applications__c app = [Select id from genesis__Applications__c limit 1];
    String appid = String.valueOf(app.id);
    List<String> applicationId = new List<String>();
    applicationId.add(appid);
    Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
    NLSModifyFieldCallout.nlsUpdateApplicationField(applicationId);
    Test.stopTest();
 }
 @isTest
 public static void testModifyField1(){
    Test.startTest();
    List<String> applicationId = new List<String>();
    Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
    NLSModifyFieldCallout.nlsUpdateApplicationField(applicationId);
    Test.stopTest();
 }
 @isTest
 public static void testModifyField2(){
    Test.startTest();
    genesis__Applications__c app = [Select id from genesis__Applications__c limit 1];
    String appid = String.valueOf(app.id);
    List<String> applicationId = new List<String>();
    applicationId.add(appid);
    Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock1() );
    NLSModifyFieldCallout.nlsUpdateApplicationField(applicationId);
    Test.stopTest();
 }
 @isTest
 public static void testModifyField3(){
    Test.startTest();
    List<intframework__Integration_API_Configuration__c> intapi = [Select intframework__Request_Mapping__c  from intframework__Integration_API_Configuration__c];
    intapi[0].intframework__Request_Mapping__c = '{ "thirdPartySystem": { "name": "Get Field", "filters": [ {"objectAPI": "genesis__Applications__c", "objectAlias": "getAppField1","fields": [{ "externalField": "loanNumber", "fieldAPI": "genesis__Loan_Number__c"},{"externalField": "creditTotalDrawLimit", "fieldAPI": "Credit_Total_Draw_Limit__c"}],"whereClause": "Id IN :appList"}]}}';
    Database.update(intapi);
    genesis__Applications__c app = [Select id from genesis__Applications__c limit 1];
    String appid = String.valueOf(app.id);
    List<String> applicationId = new List<String>();
    applicationId.add(appid);
    Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
    NLSModifyFieldCallout.nlsUpdateApplicationField(applicationId);
    Test.stopTest();
 }
}