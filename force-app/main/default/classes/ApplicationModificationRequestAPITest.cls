/**
 * @description       : Test class for ApplicationModificationRequestAPI
 * @author            : Simran
 * @group             : 
 * @last modified on  : 09-19-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class ApplicationModificationRequestAPITest {

    /**
    * @description : This is the test setup method where test data are being created
    * @author Simran | 04-03-2024 
    **/
    @TestSetup
    static void makeData(){
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        Map<String,Id> objectVsIdMap=new Map<String,Id>();
        Map<String,String> integrationFrameworkMap=new Map<String,String>();
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
        intframework__Integration_API_Type__c modifyFieldAPIType = IntegrationTestInitHelper.getIntegrationAPIType(family.id,'Approve Modification Request API Type');
        intframework__Integration_Provider__c modifyFieldProvider = IntegrationTestInitHelper.getIntegrationProvider(family.id,'Approve Modification Request Integration Provider');
        intframework__Integration_Configuration__c modifyFieldConfiguration = IntegrationTestInitHelper.getIntegrationConfiguration(modifyFieldProvider.id,'NLS Approve Modification Request Integration Configuration','NLS');
        integrationFrameworkMap.put('adapterName','NLSApproveModificationRequestAdapter');
        integrationFrameworkMap.put('method','POST');
        integrationFrameworkMap.put('endpoint','nls/xml-import');
        integrationFrameworkMap.put('longRunningOperation','NLSApproveModificationRequestAdapter');
        integrationFrameworkMap.put('priority','1');
        integrationFrameworkMap.put('contentType','application/json');
        integrationFrameworkMap.put('requestMappingJSON','{"thirdPartySystem":{"name":"Get Field","filters":[{"objectAPI":"genesis__Application_Note__c","objectAlias":"getAppNoteField","fields":[{"externalField":"loanNumber","fieldAPI":"genesis__Application__r.genesis__Loan_Number__c"},{"externalField":"maturityDate","fieldAPI":"Modified_Maturity_Date__c"},{"externalField":"applicationNoteId","fieldAPI":"Id"},{"externalField":"loanAmount","fieldAPI":"Updated_Loan_Amount__c"}],"whereClause":"Id In :appNoteId"}]}}');
        integrationFrameworkMap.put('familyId',family.id);
        integrationFrameworkMap.put('apiTypeId',modifyFieldAPIType.id);
        integrationFrameworkMap.put('providerId',modifyFieldProvider.id);
        integrationFrameworkMap.put('configId',modifyFieldConfiguration.id);
        IntegrationTestInitHelper.getIntegrationAPIConfigurationV2(integrationFrameworkMap);
        genesis__Business_Information__c businessInformationObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInformationObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInformationObj.Id, newPartnerProgramObj.id);
        Database.insert(dealerAccountObj, true);
        
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(businessInformationObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity('Individual(s) with DBA');
        Database.insert(entityObj,true);
        Account accountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,businessInformationObj.Id);
        Database.insert(accountObj,true);
        Contact contactObj=LoanServicingTestHelper.createBorrowerContact(accountObj.Id);
        Database.insert(contactObj,true);
        objectVsIdMap.put('dealerAccountId',dealerAccountObj.Id);
        objectVsIdMap.put('clProductId',clProductObj.Id);
        objectVsIdMap.put('clPurposeId',clPurposeObj.Id);
        objectVsIdMap.put('borrowerAccountId',accountObj.Id);
        objectVsIdMap.put('borrowerContactId',contactObj.Id);
        objectVsIdMap.put('clAccountId',clAccountObj.Id);
        genesis__Applications__c currApplicationObj = LoanServicingTestHelper.createCurrCropYearApplication(objectVsIdMap);
        Database.insert(currApplicationObj,true);
        genesis__Applications__c previousApplicationObj = LoanServicingTestHelper.createPrevCropYearApplication(objectVsIdMap);
        Database.insert(previousApplicationObj,true);
        clcommon__Party_Type__c partyTypeObj=LoanServicingTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(partyTypeObj,true);
        objectVsIdMap.put('accountId',accountObj.Id);
        objectVsIdMap.put('contactId',contactObj.Id);
        objectVsIdMap.put('partyTypeId',partyTypeObj.Id);
        objectVsIdMap.put('applicationId',previousApplicationObj.Id);
        clcommon__Party__c partyObj = LoanServicingTestHelper.createParty(objectVsIdMap);
        Database.insert(partyObj,true);
        objectVsIdMap.put('applicationId',currApplicationObj.Id);
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(objectVsIdMap);
        Database.insert(borrowerPartyObj,true);
        testSetupOtherDetails(currApplicationObj,previousApplicationObj);
    } 

    /**
    * @description : Method to insert more details required for this test class. Setup method is further broken down into this method to avoid long methods. 
    * @author Simran | 04-03-2024 
    * @param currApplication 
    * @param previousYearApplication 
    **/
    static void testSetupOtherDetails(genesis__Applications__c currApplication,genesis__Applications__c previousYearApplication){
        genesis__Application_Note__c approvedAppNoteObj=LoanServicingTestHelper.createApproveApplicationNote(currApplication);
        Database.insert(approvedAppNoteObj,true);
        genesis__Application_Note__c declinedAppNoteObj=LoanServicingTestHelper.createDeclineApplicationNote(previousYearApplication);
        Database.insert(declinedAppNoteObj,true);

    }

    /**
     * @description       : purpose of this class is to set the mock and generate response for testing
     * @author            : Simran
     * @group             : 
     * @last modified on  : 09-19-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSModifyFieldHttpCalloutMock implements HttpCalloutMock {
        /**
        * @description - Purpose of this method is to generate response
        * @author Simran | 08-03-2023 
        * @param request
        * @return HTTPResponse 
        **/
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
     * @description       : purpose of this class is to set the mock and generate response for testing
     * @author            : Simran
     * @group             : 
     * @last modified on  : 09-19-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSModifyFieldHttpStatusCodeCalloutMock implements HttpCalloutMock {
        /**
       * @description - Purpose of this method is to generate response
       * @author Simran | 08-03-2023 
       * @param request
       * @return HTTPResponse 
       **/
       public HTTPResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
           response.setStatusCode(500);
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
     * @description       : purpose of this class is to set the mock and generate response for testing
     * @author            : Simran
     * @group             : 
     * @last modified on  : 09-19-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSModifyFieldHttpCalloutExceptionMock implements HttpCalloutMock {
         /**
        * @description - Purpose of this method is to generate response
        * @author Simran | 08-03-2023 
        * @param request
        * @return HTTPResponse 
        **/
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

    
    /**
    * @description : This method is used to check the approve modification request for CFA Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testApproveModificationForCFA(){
        Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Modified_Maturity_Date__c, Updated_Loan_Amount__c ,Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:appObj.Id];
        if(userObj != null){
            Test.startTest();
            System.runAs(userObj){
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(ConstantValues.SUCCESS_MODIFICATION_MESSAGE, response,'Success'); 
            }
            Test.stopTest();
        }
    }

    /**
    * @description : This method is used to check the approve modification request for Landus Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testApproveModificationForLandus(){
        Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
        Account dealerAccount=[SELECT Id, Coop_Type__c FROM Account WHERE Name='Kisan Loan' LIMIT 1];
        dealerAccount.Coop_Type__c='Landus';
        Database.update(dealerAccount,true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Modified_Maturity_Date__c, Updated_Loan_Amount__c ,Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:appObj.Id];
        if(userObj != null){
            Test.startTest();
            System.runAs(userObj){
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(ConstantValues.SUCCESS_MODIFICATION_MESSAGE, response,'Success'); 
            }
            Test.stopTest();
        }
    }

    /**
    * @description : This method is used to check the approve modification request for GMK Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testApproveModificationForGMK(){
        Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
        Account dealerAccount=[SELECT Id, Coop_Type__c FROM Account WHERE Name='Kisan Loan' LIMIT 1];
        dealerAccount.Coop_Type__c='Growmark';
        Database.update(dealerAccount,true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Modified_Maturity_Date__c, Updated_Loan_Amount__c ,Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:appObj.Id];
        if(userObj != null){
            Test.startTest();
            System.runAs(userObj){
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(ConstantValues.SUCCESS_MODIFICATION_MESSAGE, response,'Success'); 
            }
            Test.stopTest();
        }
    }

    /**
    * @description : This method is used to check the user access
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testUserAccess(){
        genesis__Applications__c appObj = [SELECT Id,genesis__Contact__c,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Modified_Maturity_Date__c, Updated_Loan_Amount__c ,Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:appObj.Id];
        User userObj = LoanServicingTestHelper.createCLUser(appObj.genesis__Contact__c);
        if(userObj != null){
            Test.startTest();
            System.runAs(userObj){
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(null, response,'Insufficient Access');  

            }
            Test.stopTest();
        }
    }
    
    /**
    * @description : This method is used to check the custom exception by providing null as a parameter while calling the nls
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void checkCustomException(){
        Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        if(userObj != null){
            Test.startTest();
            System.runAs(userObj){
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,null,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(null, response,'ERROR: Required parameter is Missing.'); 
            }
            Test.stopTest();
        }
    }
  
    /**
    * @description : This method is used to test exception by providing wrong application note record id
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void checkkAppNoteId(){
        Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
       
        if(userObj != null){
            Test.startTest();
            System.runAs(userObj){
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,appObj.Id,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(null, response,''); 
            }
            Test.stopTest();
        }
    }

    /**
    * @description : This method is test exception in NLSApproveModificationRequestAdapter cls when access token is null.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testNLSApproveAdapterException(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:appObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutExceptionMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(appObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_APPROVE_STATUS);
                System.assertEquals(ConstantValues.SUCCESS_MODIFICATION_MESSAGE, response,'Success'); 
            }
        }
    }
     
    /**
    * @description : This method is used to check the decline modification request for CFA Coop Type..
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testDeclineModificationForCFA(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_DECLINE_STATUS);
                System.assertEquals(ConstantValues.MATURITY_DECLINATION_MESSAGE, response,'Decline'); 
            }
        }
    }

    /**
    * @description : This method is used to check the decline modification request for Landus Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testDeclineModificationForLandus(){
        Account dealerAccount=[SELECT Id, Coop_Type__c FROM Account WHERE Name='Kisan Loan' LIMIT 1];
        dealerAccount.Coop_Type__c='Landus';
        Database.update(dealerAccount,true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_DECLINE_STATUS);
                System.assertEquals(ConstantValues.MATURITY_DECLINATION_MESSAGE, response,'Decline'); 
            }
        }
    }

    /**
    * @description : This method is used to check the decline modification request for GMK Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testDeclineModificationForGMK(){
        Account dealerAccount=[SELECT Id, Coop_Type__c FROM Account WHERE Name='Kisan Loan' LIMIT 1];
        dealerAccount.Coop_Type__c='Growmark';
        Database.update(dealerAccount,true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,ConstantValues.APPLICATION_NOTE_DECLINE_STATUS);
                System.assertEquals(ConstantValues.MATURITY_DECLINATION_MESSAGE, response,'Decline'); 
            }
        }
    }

    /**
    * @description : This method is used to check the failed modification request for CFA Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testFailedModificationForCFA(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,'failed');
                System.assertEquals(ConstantValues.FAILED_MODIFICATION_MESSAGE, response,'Failed'); 
            }
        }
    }

    /**
    * @description : This method is used to check the failed modification request for Landus Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testFailedModificationForLandus(){
        Account dealerAccount=[SELECT Id, Coop_Type__c FROM Account WHERE Name='Kisan Loan' LIMIT 1];
        dealerAccount.Coop_Type__c='Landus';
        Database.update(dealerAccount,true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,'failed');
                System.assertEquals(ConstantValues.FAILED_MODIFICATION_MESSAGE, response,'Failed'); 
            }
        }
    }

    /**
    * @description : This method is used to check the failed modification request for GMK Coop Type.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testFailedModificationForGMK(){
        Account dealerAccount=[SELECT Id, Coop_Type__c FROM Account WHERE Name='Kisan Loan' LIMIT 1];
        dealerAccount.Coop_Type__c='Growmark';
        Database.update(dealerAccount,true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,'failed');
                System.assertEquals(ConstantValues.FAILED_MODIFICATION_MESSAGE, response,'Failed'); 
            }
        }
    }

    /**
    * @description : This method is used to check modification status by providing any other application note status other than approve/decline/failed.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testModificationStatus(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c currAppObj = [SELECT Id,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023457' LIMIT 1];
        genesis__Application_Note__c appNoteObj=[SELECT Id, Status__c FROM genesis__Application_Note__c WHERE genesis__Application__c=:currAppObj.Id];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS(currAppObj.Id,appNoteObj.Id,'abc');
                System.assertEquals(ConstantValues.FAILED_MODIFICATION_MESSAGE, response,'Failed'); 
            }
        }
    }

    /**
    * @description : This is used to check the missing parameter and throw exception accordingly.
    * @author Simran | 04-03-2024 
    **/
    @isTest
    public static void testParameterMissingCustomException(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        if(userObj != null){
            System.runAs(userObj){
                Test.setMock(HttpCalloutMock.class, new NLSModifyFieldHttpCalloutMock());
                String response = ApplicationModificationRequestAPI.modificationRequestWS('','','');
                System.assertEquals(null, response,'Paramater Missing exception');
            }
        }
    }
}