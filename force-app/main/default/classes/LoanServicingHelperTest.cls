/**
 * @description       : Test Class For LoanServicingHelper
 * @author            : Ayush Kumar Singh 
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class LoanServicingHelperTest {
    
    /**
    * @description - Create Test Data
    * @author Sk Minsar | 12-18-2024 
    **/
    @TestSetup
    static void makeData(){
        clcommon__Legal_Entity__c clEntity= ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(clEntity, true);
        
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Coop_Type__c = PortalConstants.LANDUS_COOP_TYPE;
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId'=> clAccountObj.Id,
            'contactId'=> clContactObj.Id,
            'partyTypeId'=> clPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        Database.insert(clPartyObj, true);

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(borrowerPartyObj);

        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(prPartyTypeObj,true);
        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        Database.insert(principalPartyObj,true);
        TestClassHelper.createPricingDetail(applicationObj.Id);
    }

    /**
    * @description - Returns the cl User
    * @author Sk Minsar | 12-18-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser(){
        return [SELECT Id, Name, AccountId, Account.ParentId, ContactId FROM User WHERE UserName='ross.geller@yopmail.com' LIMIT 1];
    }

    /**
    * @description - returns contentLink
    * @author Sk Minsar | 12-18-2024 
    * @param csvString 
    * @return String 
    **/
    private static String getContentLink(String csvString){
        User clUser = getCertifiedLenderUser();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:clUser.ContactId LIMIT 1];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId LIMIT 1];
        Blob bodyBlob = Blob.valueOf(csvString);   
        ContentVersion firstContentVersion = new ContentVersion(
            Title='TestTitle', 
            PathOnClient ='TestACH.csv',
            VersionData = bodyBlob, 
            origin = 'C'
        );
        Database.insert(firstContentVersion,true);
        ContentVersion secondContentVersion = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :firstContentVersion.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objAccount.Id;
        contentlink.contentdocumentid = secondContentVersion.contentDocumentId;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';
        Database.insert(contentlink,true);
        return String.valueOf(contentlink.Id);
    }
   
    /**
    * @description :Setting up the mock response
    */
    public class LoanServicingHelperTesthMock implements HttpCalloutMock {
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
     * @description : Method to test getNLSAccessToken
     * @author Suraj Kumar | 11-25-2024 
     **/
    @isTest
    private static void testgetNLSAccessToken(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LoanServicingHelperTesthMock());
            String accesstoken = LoanServicingHelper.getNLSAccessToken();
            System.assertEquals(true, accesstoken!= null, 'Assertion Failed');
            Test.stopTest();
            }
    }

    /**
     * @description : Test method for sendEmailToLandusGrower
     * @author Suraj Kumar | 11-25-2024 
     **/
    @isTest
    private static void testSendEmailToLandusGrower(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Name,
                                                                Coop_Type__c,
                                                                genesis__Loan_Number__c,
                                                                Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                                genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                                                genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                genesis__Contact__r.Email
                                                                FROM genesis__Applications__c LIMIT 1];
        User adminUser = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
                Test.startTest();                                                     
                LoanServicingHelper.sendEmailToLandusGrower(applicationList[0]);
                List<clcommon__Notification__c> notificationList = [SELECT ID FROM clcommon__Notification__c];
                System.assertEquals(true, notificationList.size()>0,'Assertion Failed');
                Test.stopTest();
            }
    }

    /**
    * @description : Test method for sendEmailToLandusGrower
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testSendEmailToLandusGrowerForCorportation(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Name,
                                                                Coop_Type__c,
                                                                genesis__Account__c,
                                                                genesis__Loan_Number__c,
                                                                Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                                genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                                                genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                genesis__Contact__r.Email
                                                                FROM genesis__Applications__c LIMIT 1];
        User adminUser = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();                                                     
            LoanServicingHelper.sendEmailToLandusGrower(applicationList[0]);
            List<clcommon__Notification__c> notificationList = [SELECT ID FROM clcommon__Notification__c];
            System.assertEquals(true, notificationList.size()>0,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for storeGenericRequestBody
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testStoreGenericRequestBody(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            LoanServicingHelper.storeGenericRequestBody('Draw Limit','- Request Body','request');
            System.assertEquals('','', 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for storeGenericResponseBody
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testStoreGenericResponseBody(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            LoanServicingHelper.storeGenericResponseBody('Draw Limit','- Response Body','response');
            System.assertEquals('','', 'Assertion Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test method for checkEmptyString
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testEmptyString(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Boolean exceptionThrown = false;
            try{
                LoanServicingHelper.checkEmptyString('','String is Empty Exception');
            }catch(CustomException e){
                exceptionThrown = true;
            }
            System.assertEquals(true, exceptionThrown, 'Exception for Empty String');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getStatus
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testBlankStatus(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getStatus('',false);
            System.assertEquals(PortalConstants.STATUS_PENDING, result, 'Expected status to be PENDING for blank status');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getStatus
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testVoidedStatus(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getStatus('Voided',false);
            System.assertEquals(PortalConstants.STATUS_VOIDED, result, 'Expected status to be VOIDED for VOIDED status');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getStatus
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPendingStatus(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getStatus('Pending',false);
            System.assertEquals(PortalConstants.STATUS_PENDING, result, 'Expected status to be Pending for Pending status');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getStatus
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedStatus(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getStatus('Posted',true);
            System.assertEquals(PortalConstants.STATUS_POSTED, result, 'Expected status to be POSTED when posted to NLS');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getPostedTransactionType
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedTransactionTypeOthers(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getPostedTransactionType('Others', '');
            System.assertEquals('Others', result, 'Expected transactions type to be Others');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getPostedTransactionType
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedTransactionTypeDraft(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getPostedTransactionType(PortalConstants.NLS_DRAFT_ADVANCE, '');
            System.assertEquals(ConstantValues.DRAFT , result, 'Expected transactions type to be Others');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getPostedTransactionType
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedTransactionTypeACH(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getPostedTransactionType(PortalConstants.NLS_PRINCIPAL_ADVANCE, '');
            System.assertEquals(ConstantValues.ACH, result, 'Expected transactions type to be Principal Advance');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getPostedTransactionType
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedTransactionTypePayment(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getPostedTransactionType('', PortalConstants.NLS_ACH_COMMERCE);
            System.assertEquals(ConstantValues.PAYMENT, result, 'Expected transactions type to be Principal Reduction');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getPostedTransactionType
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedTransactionTypeMobileDeposit(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getPostedTransactionType('', PortalConstants.NLS_CHECK_COMMERCE);
            System.assertEquals(ConstantValues.MOBILE_DEPOSIT, result, 'Expected transactions type to be Principal Reduction');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for getPostedTransactionType
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testPostedTransactionTypeProductReturn(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String result = LoanServicingHelper.getPostedTransactionType(PortalConstants.NLS_PRODUCT_RETURN, '');
            System.assertEquals(ConstantValues.PRODUCT_RETURN, result, 'Expected transactions type to be Product Return');
            Test.stopTest();
        }
    }
    /**
    * @description : Test method for isEmptyString
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testIsEmptyStringTrue(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Boolean result = LoanServicingHelper.isEmptyString('Hello', 'Hello');
            System.assertEquals(false, result, 'Error: Empty String');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for isEmptyString
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testIsEmptyStringFalse(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Boolean result = LoanServicingHelper.isEmptyString('', 'ello');
            System.assertEquals(true, result, 'Error: Non Empty String');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for filterAndSortTransactions
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testfilterAndSortTransactions(){
        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put(PortalConstants.KEY_FROM_DATE, '02/15/2024');
        dataMap.put(PortalConstants.KEY_TO_DATE, '02/16/3099');
        dataMap.put(ConstantValues.DEALER_COOP_TYPE, 'CFA');
        List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>> {
            new Map<String, Object> {
                PortalConstants.KEY_CREATED_DATE => System.now().addDays(1),
                PortalConstants.KEY_TRANSACTION_TYPE => PortalConstants.DRAFT
            },
            new Map<String, Object> {
                PortalConstants.KEY_CREATED_DATE => System.now(),
                PortalConstants.KEY_TRANSACTION_TYPE => PortalConstants.DRAFT
            }
        };

        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<Map<String, Object>> result = LoanServicingHelper.filterAndSortTransactions(postedTransactionsList, dataMap);
            System.assertEquals(postedTransactionsList, result, 'Error');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for filterAndSortTransactions
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testfilterAndSortTransactionsSort(){
        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put(PortalConstants.KEY_FROM_DATE, '02/15/2024');
        dataMap.put(PortalConstants.KEY_TO_DATE, '02/16/3099');
        dataMap.put(ConstantValues.DEALER_COOP_TYPE, 'CFA');
        List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>> {
            new Map<String, Object> {
                PortalConstants.KEY_CREATED_DATE => System.now(),
                PortalConstants.KEY_TRANSACTION_TYPE => PortalConstants.DRAFT
            },
            new Map<String, Object> {
                PortalConstants.KEY_CREATED_DATE => System.now().addDays(1),
                PortalConstants.KEY_TRANSACTION_TYPE => PortalConstants.DRAFT
            }
        };

        List<Map<String, Object>> expectedResultList = new List<Map<String, Object>>();
        expectedResultList.add(postedTransactionsList[1]);
        expectedResultList.add(postedTransactionsList[0]);

        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<Map<String, Object>> result = LoanServicingHelper.filterAndSortTransactions(postedTransactionsList, dataMap);
            System.assertEquals(expectedResultList, result, 'Error');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for filterAndSortTransactions
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testfilterAndSortTransactionsEmptyDate(){ 
        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put(PortalConstants.KEY_FROM_DATE, '');
        dataMap.put(PortalConstants.KEY_TO_DATE, '');
        dataMap.put(ConstantValues.DEALER_COOP_TYPE, 'Growmark');
        List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>> {};

        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<Map<String, Object>> result = LoanServicingHelper.filterAndSortTransactions(postedTransactionsList, dataMap);
            System.assertEquals(postedTransactionsList, result, 'Error');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method for excludeGmkDraftTransactions
    * @author Suraj Kumar | 11-25-2024 
    **/
    @isTest
    private static void testexcludeGmkDraftTransactions(){
        String dealerCoopType = PortalConstants.GROWMARK_COOP_TYPE;
        List<Map<String, Object>> postedTransactionsList = new List<Map<String, Object>> {
            new Map<String, Object> {
                PortalConstants.KEY_CREATED_DATE => System.now().addDays(1),
                PortalConstants.KEY_TRANSACTION_TYPE => PortalConstants.ACH
            },
            new Map<String, Object> {
                PortalConstants.KEY_CREATED_DATE => System.now(),
                PortalConstants.KEY_TRANSACTION_TYPE => PortalConstants.ACH
            }
        };

        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<Map<String, Object>> result = LoanServicingHelper.excludeGmkDraftTransactions(postedTransactionsList, dealerCoopType);
            System.assertEquals(postedTransactionsList, result, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description - Test with different year
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testCloseMaturityProductReturn(){
        Date currentDate = Date.today();
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try {
                LoanServicingHelper.validateCloseMaturityProductReturn( Date.newInstance(currentDate.year()-1, 1, 27), Date.newInstance(currentDate.year(), 1, 1));
            } catch (CustomException customExceptionObj){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test with Same year
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testCloseMaturityProductReturnCurrentDate(){
        Date currentDate = Date.today();
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try {
                LoanServicingHelper.validateCloseMaturityProductReturn(Date.newInstance(currentDate.year(), 1, 27), Date.newInstance(currentDate.year(), 2, 1));
            } catch (CustomException customExceptionObj){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }


    /**
    * @description - Test validateLoanId
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testValidateLoanId(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try {
                LoanServicingHelper.validateLoanId(null);
            } catch (CustomException customExceptionObj){
                isExceptionThrown = true;
            }
            System.assertEquals(true, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test saveExceptionLog
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testSaveExceptionLog(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.saveExceptionLog(null, 'CustomException');
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validatePastDueLoan method
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testValidatePastDueLoan(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<genesis__Applications__c> appList = [SELECT Id, Name, genesis__Account__c, genesis__Maturity_Date__c, genesis__Status__c, Past_Due_Amount__c FROM genesis__Applications__c LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try {
                LoanServicingHelper.validatePastDueLoan(appList);
            } catch (CustomException customExceptionObj){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }


    /**
    * @description - Test isNotNumeric true 
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testIsNotNumericTrue(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Boolean responseStatus = LoanServicingHelper.isNotNumeric('ab123');
            System.assertEquals(responseStatus, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - isNotNumeric false value
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testIsNotNumericFalse(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Boolean responseStatus = LoanServicingHelper.isNotNumeric('123');
            System.assertEquals(responseStatus, false, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test getLoggedInUserDealerId 
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testLoggedInUserDealerId (){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.getLoggedInUserDealerId();
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test getParentLoanNumberMap 
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void tesParentLoanNumberMap(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String responseDealerId = LoanServicingHelper.getParentLoanNumberMap('123456-A');
            System.assertEquals(responseDealerId, '123456', PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test getCommaEscapedRecord 
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testCommaEscapedRecord(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<String> responseList = LoanServicingHelper.getCommaEscapedRecord('123234345-A,Test1,150000\n123234345-A,Test2,1000');
            System.assertEquals(responseList.size()!=0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidateCSVRecordData
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testValidateCSVRecordData(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.isValidateCSVRecordData(new String[]{'123234345-A','Test A, Test B', '10'});
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, false, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test getcsvFileLinesList method
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testCsvFileLinesList(){
        String contentLink = getContentLink('123234345-A,Test1,150000\n123234345-A,Test2,1000');
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<String> responseList = LoanServicingHelper.getcsvFileLinesList(new Map<String, Object>{PortalConstants.ID_KEY => contentLink});
            System.assertEquals(responseList.size()>0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test Sufficient fund check
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testSufficientFundCheck(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        genesis__Application_Pricing_Detail__c pricingDetail = [SELECT Id, Name, genesis__Application__r.Available__c FROM genesis__Application_Pricing_Detail__c LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.sufficientFundCheck(pricingDetail, 500);
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Sufficiend fund check for map of laon number
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testSufficientFundCheckForLoanMap(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        genesis__Application_Pricing_Detail__c pricingDetail = [SELECT Id, Name, Loan_Number__c, genesis__Application__r.Available__c FROM genesis__Application_Pricing_Detail__c LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.sufficientFundCheck(new Map<String, String>{ String.valueOf(pricingDetail.Loan_Number__c) => '100'}, pricingDetail);
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Check isValid loan number
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testValidLoanNumber(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        genesis__Application_Pricing_Detail__c pricingDetail = [SELECT Id, Name, Loan_Number__c, genesis__Application__r.Available__c FROM genesis__Application_Pricing_Detail__c LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.isValidLoanNumber(new List<String>{String.valueOf(pricingDetail.Loan_Number__c)});
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, true, PortalConstants.ASSERTION_FAILED);
            
            Test.stopTest();
        }
    }

    /**
    * @description - Test getFilteredCSVDataMap
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testGetFilteredCSVDataMap(){
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            Map<String, Object> responseMap = LoanServicingHelper.getFilteredCSVDataMap(new List<String>{'123234345-A,Test1,150000','123234345-A,Test2,1000'});
            System.assertEquals(responseMap!=null, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test getFilteredCSVDataMap
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testValidateCSVFormat(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.validateCSVFormat(new String[]{'123234345-A','Test A, Test B', '10'});
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test getFilteredCSVDataMap
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testCheckEmptyList(){
        Boolean isExceptionThrown = false;
        User userObj = [SELECT Id FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                LoanServicingHelper.checkEmptyList(new List<String>{}, 'Custom exception');
            }catch(Exception e){
                isExceptionThrown = true;
            }
            System.assertEquals(isExceptionThrown, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
}