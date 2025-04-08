/**
 * @description       : 
 * @author            : E. Shalini
 * @group             : 
 * @last modified on  : 05-30-2022
 * @last modified by  : E. Shalini
**/
@isTest
public with sharing class NLSCifBookToCoreHttpCalloutMock {

    public static ints__Integration_Configuration__c insertICFramework(Map<String,String> integrationConfigMap){
        ints__Integration_Configuration__c objIntegrationConfiguration = new ints__Integration_Configuration__c();
        objIntegrationConfiguration.name = (integrationConfigMap.get('Name') != NULL) ? integrationConfigMap.get('Name') : '';
        objIntegrationConfiguration.ints__Third_Party_System__c = (integrationConfigMap.get('Third Party') != NULL) ? integrationConfigMap.get('Third Party') : '';
        objIntegrationConfiguration.ints__Type__c = (integrationConfigMap.get('Integration Type') != NULL) ? integrationConfigMap.get('Integration Type') : '';
        objIntegrationConfiguration.ints__Authorization_Named_Credential__c = (integrationConfigMap.get('Authorization Named Credential') != NULL) ? integrationConfigMap.get('Authorization Named Credential') : '';
        objIntegrationConfiguration.ints__Integration_Service__c = (integrationConfigMap.get('Integration Service') != NULL) ? integrationConfigMap.get('Integration Service') : '';
        objIntegrationConfiguration.ints__Active__c = true;
        objIntegrationConfiguration.ints__Request_Mapping__c = (integrationConfigMap.get('Request Mapping') != NULL) ? integrationConfigMap.get('Request Mapping') : '';
        objIntegrationConfiguration.ints__Execution_Priority__c = Decimal.valueOf((integrationConfigMap.get('Execution Priority') != NULL) ? integrationConfigMap.get('Execution Priority') : '0');
        objIntegrationConfiguration.ints__Adaptor_Class__c = (integrationConfigMap.get('Adapter Class') != NULL) ? integrationConfigMap.get('Adapter Class') : '';
        objIntegrationConfiguration.ints__API_Named_Credential__c = (integrationConfigMap.get('Authorization Credential') != NULL) ? integrationConfigMap.get('Authorization Credential') : '';
        objIntegrationConfiguration.ints__Response_Mapping__c = '{"StorageConfiguration":{"StoreInDB":"False"},"DMLOperations":[]}';
        objIntegrationConfiguration.ints__API_Endpoint__c = (integrationConfigMap.get('Endpoint') != NULL) ? integrationConfigMap.get('Endpoint') : '';
        objIntegrationConfiguration.ints__Use_Mocker__c = true;
        objIntegrationConfiguration.ints__HTTP_Method__c = 'POST';
        insert objIntegrationConfiguration;
        List<ints__Integration_Configuration__c> integrationConfigList= [SELECT id,
                                                                                ints__Use_Mocker__c
                                                                                FROM ints__Integration_Configuration__c
                                                                                WHERE ints__Use_Mocker__c = true];
        System.assertEquals(true, integrationConfigList[0].ints__Use_Mocker__c, 'Integration Configuration should be created');
        ints__Integration_Configuration__c integrationConfigurationRecord = objIntegrationConfiguration;
        
        return objIntegrationConfiguration;
        }

    public ints__Mocker__c respond(String request, Id id) {

    
            ints__Mocker__c objMocker = new ints__Mocker__c();

//ints__Integration_Configuration__c objIntegrationConfiguration= new ints__Integration_Configuration__c ();

        objMocker.ints__Integration_Configuration__c = id;

        objMocker.ints__Response_Status__c = '200 - OK';

        objMocker.ints__content_Type__c = 'application/xml';

        if(request =='token'){
             String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
             objMocker.ints__Response_Body__c = token;
        }
        else {
            objMocker.ints__Response_Body__c= '{ "status": { "code": 200, "message": "string" }, "payload": { "data": "string" } }';
        }

insert objMocker;

List<ints__Mocker__c> integrationMockList = [SELECT id,

                                                        name,

                                                        ints__Control_Field_Value__c,

                                                        ints__Response_Status__c,

                                                        ints__content_Type__c

                                                    FROM ints__Mocker__c

                                                    WHERE ints__Response_Status__c = '200 - OK'];

    System.assertequals('200 - OK', integrationMockList[0].ints__Response_Status__c, 'Mocker Object should be Created');

    return integrationMockList[0];
    }
}