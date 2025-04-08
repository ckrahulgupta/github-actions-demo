/**
 * @description       : Test class of PortalPendingItemsAPI
 * @author            : Rahul Gupta | 22-04-2022
 * @group             : 
 * @last modified on  : 11-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
public class TestPortalPendingItemsAPI {

    @TestSetup
    static void makeData() {

        // create business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // create dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        DataBase.insert(dealerAccountObj);
                    
        // creating user for certified lender
        genesis__Business_Information__c clBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(clBusinessInfoObj,true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(clBusinessInfoObj.Id,dealerAccountObj.Id);
        clAccountObj.Name = 'Ross Geller';
        Database.insert(clAccountObj,true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        clContactObj.FirstName = 'Ross';
        clContactObj.LastName = 'Geller';
        Database.insert(clContactObj,true);
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj,true);

        clcommon__Reciprocal_Role__c clRoleObj = new clcommon__Reciprocal_Role__c(Name='Certified Lender');
        Database.insert(clRoleObj, false);
        clcommon__Relationship__c dealerCLrelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(dealerCLrelationObj, false);


        // create legal entity
        clcommon__Legal_Entity__c legalEntityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        // create borrower
        genesis__Business_Information__c borrowerBIObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBIObj,true);
        
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBIObj.Id);
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // create loan product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        //create dealer applicant relationship
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(relationObj,true);

        // create application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'clAccountObjId' => clAccountObj.id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(applicationDataMap);
        Database.insert(applicationObj,true);

        // create borrower party type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        Database.insert(borrowerPartyTypeObj);

        // create certified lender party
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        Database.insert(clPartyTypeObj,true);

        // create certified lender party
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        Database.insert(dealerPartyTypeObj,true);

        // create borrower party
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        Database.insert(partyObj,true);

        // create certified lender party
        Map<String,Id> clpartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clpartyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);

        // create dealer party
        Map<String,Id> dealerpartyParamMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.id,
            'partyTypeId' => dealerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(dealerpartyParamMap);
        Database.insert(dealerPartyObj,true);

        // create document category
        List<clcommon__Document_Category__c> documentCategoryList = new List<clcommon__Document_Category__c>();
        documentCategoryList.add(ApplicationOriginationTestHelper.createDocumentCategory(new Map<String,String>{
                                                                                                'applicationId' => applicationObj.id,
                                                                                                'status' => 'OPEN',
                                                                                                'showInPortal' => 'UPLOAD_VIA_PORTAL',
                                                                                                'categoryName' => 'Signed Credit Agreement'
                                                                                        }));
        documentCategoryList.add(ApplicationOriginationTestHelper.createDocumentCategory(new Map<String,String>{
                                                                                                'applicationId' => applicationObj.id,
                                                                                                'status' => 'OPEN',
                                                                                                'showInPortal' => 'UPLOAD_VIA_PORTAL',
                                                                                                'categoryName' => 'Lien Search'
                                                                                        }));
        documentCategoryList.add(ApplicationOriginationTestHelper.createDocumentCategory(new Map<String,String>{
                                                                                                'applicationId' => applicationObj.id,
                                                                                                'status' => 'OPEN',
                                                                                                'showInPortal' => 'UPLOAD_VIA_PORTAL',
                                                                                                'categoryName' => 'Miscellaneous'
                                                                                        }));
        documentCategoryList.add(ApplicationOriginationTestHelper.createDocumentCategory(new Map<String,String>{
                                                                                                'applicationId' => applicationObj.id,
                                                                                                'status' => 'OPEN',
                                                                                                'showInPortal' => 'UPLOAD_VIA_PORTAL',
                                                                                                'categoryName' => 'Notice of Security Interest'
                                                                                        }));
        Database.insert(documentCategoryList);

        // create task
        List<Task> taskList = new List<Task>();
        taskList.add(ApplicationOriginationTestHelper.createTask(new Map<String,String>{
                                                                         'applicationId' => applicationObj.id,
                                                                         'status' => 'Completed',
                                                                         'subject' => 'Signed Credit Agreement',
                                                                         'comments' => 'This is a test comment'
                                                                }));
        taskList.add(ApplicationOriginationTestHelper.createTask(new Map<String,String>{
                                                                        'applicationId' => applicationObj.id,
                                                                        'status' => 'Completed',
                                                                        'subject' => 'Lien Search',
                                                                        'comments' => 'This is a test comment'
                                                                }));
        taskList.add(ApplicationOriginationTestHelper.createTask(new Map<String,String>{
                                                                        'applicationId' => applicationObj.id,
                                                                        'status' => 'OPEN',
                                                                        'subject' => 'Test Task',
                                                                        'comments' => 'This is a test comment'
                                                                }));
        taskList.add(ApplicationOriginationTestHelper.createTask(new Map<String,String>{
                                                                        'applicationId' => applicationObj.id,
                                                                        'status' => 'OPEN',
                                                                        'subject' => 'Miscellaneous',
                                                                        'comments' => 'This is a test comment'
                                                                }));
        Database.insert(taskList);
    }

    /**
    * @description Method is used to get the CL user Id
    * @author Simran | 03-08-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
       
        List<User> userList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];
                                    
        if (userList.size() == 1) {
            return userList[0];
        } 
        
        return null;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @IsTest
    public static void testPendingItems() {
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('fetchType', 'pendingItems');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalPendingItemsAPI saveApi = new PortalPendingItemsAPI();
                clcommon.Response resp = saveApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @IsTest
    public static void testAdditionalItems() {
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('fetchType', 'additionalItems');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalPendingItemsAPI saveApi = new PortalPendingItemsAPI();
                clcommon.Response resp = saveApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @IsTest
    public static void testNullFetchTypes() {
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('fetchType', 'abc');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalPendingItemsAPI saveApi = new PortalPendingItemsAPI();
                clcommon.Response resp = saveApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @IsTest
    public static void testUserException() {
        User certifiedLenderUserObj = [SELECT id FROM USER WHERE profile.name = 'Grower' AND isActive = true LIMIT 1]; 

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('fetchType', 'additionalItems');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalPendingItemsAPI saveApi = new PortalPendingItemsAPI();
                clcommon.Response resp = saveApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @IsTest
    public static void testNullException() {
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('applicationId', null);
        request.put('fetchType', 'additionalItems');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalPendingItemsAPI saveApi = new PortalPendingItemsAPI();
                clcommon.Response resp = saveApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @IsTest
    public static void testInvalidException() {
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('applicationId', true);
        request.put('fetchType', 'additionalItems');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalPendingItemsAPI saveApi = new PortalPendingItemsAPI();
                clcommon.Response resp = saveApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }
}