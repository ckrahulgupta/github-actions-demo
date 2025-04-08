/**
 * @description       : Method to test PortalUpdateLoanDetailsAPI class
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
private with sharing class PortalUpdateLoanDetailsAPITest {
   /**
   * @description : test setup
   * @author Shristy Kumari | 01-09-2025 
   **/
   @TestSetup
   private static void makeData(){
     // Creating Legal Entity for Borrower
     clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
     Database.insert(entityObj, true);
     // Creating Business Information
     genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
     Database.insert(dealerBusinessInfoObj, true);

     // Creating Account for Dealer,Cl,Sales agent and salesagent admin
     Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
     Database.insert(dealerAccountObj, true);

     Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
     Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
     Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
     Database.insert(new List<Account>{clAccountObj, saAccountObj, borrowerAccountObj},true);

     Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
     Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
     Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
     Database.insert(new List<Contact>{clContactObj, saContactObj, borrowerContactObj},true);

     User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
     User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
     User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
     Database.insert(new List<User>{clUserObj, saUserObj, borrowerUserObj},true);

     // Creating CL Purpose of Application
     clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
     Database.insert(clPurposeObj, true);
     // Creating Cl Product of Application
     clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
     Database.insert(clProductObj, true);
     // Creating map for Application
     Map<String,Id> paramForApplicationMap = new Map<String,Id>();
     paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
     paramForApplicationMap.put('clProductId', clProductObj.Id);
     paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
     paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
     paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
     paramForApplicationMap.put('clAccountId', clAccountObj.Id);
     // Creating Application
     genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
     Database.insert(applicationObj, true);
     // Creating Reciprocal Role 
     clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
     //creating related sales agent  role
     clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
     Database.insert(new List<clcommon__Reciprocal_Role__c>{roleObj, saRoleObj},true);
     // Creating Relationship between Dealer and Certified Lender
     clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
     //creating related sales agent  relationship
     clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(saRoleObj,saAccountObj.Id,saAccountObj.Id);
     Database.insert(new List<clcommon__Relationship__c>{clDealerRelationshipObj, relationshipObject},true);

    
     // Creating Certified lender Party Type
     clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
     clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
     clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
     Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj,borrowerPartyTypeObj,saPartyTypeObj}, true);
     //Creating Certified Lender Party
     Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
     paramForCLPartyMap.put('accountId', clAccountObj.Id);
     paramForCLPartyMap.put('contactId', clContactObj.Id);
     paramForCLPartyMap.put('partyTypeId', clPartyTypeObj.Id);
     paramForCLPartyMap.put('applicationId', applicationObj.Id);
     clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
     // Creating Borrower Party
     Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
     paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
     paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
     paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
     paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
     clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
     // Creating sales agent Party
     Map<String,Id> paramForSaPartyMap = new Map<String,Id>();
     paramForSaPartyMap.put('accountId', saAccountObj.Id);
     paramForSaPartyMap.put('contactId', saContactObj.Id);
     paramForSaPartyMap.put('partyTypeId', saPartyTypeObj.Id);
     paramForSaPartyMap.put('applicationId', null);
     clcommon__Party__c saPartyObj = ApplicationOriginationTestHelper.createParty(paramForSaPartyMap);
     Database.insert(new List<clcommon__Party__c>{clPartyObj,borrowerPartyObj,saPartyObj}, true);
     clcommon__document_category__c docCategory = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id,'liscense');
     Database.insert(docCategory,true);
    }
     /**
    * @description Method to get CL user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getClUser(){
        List<User> objClUserList = [SELECT Id,
                                         UserName
                                    FROM User 
                                    WHERE UserName='ross.geller@yopmail.com'
                                    LIMIT 1];
                                    
            if(objClUserList.size() == 1){
                return objClUserList[0];
            } 
        return null;
    }
     /**
    * @description Method to get Borrower user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getBorrowerUser(){
        List<User> objBorrowerUserList = [SELECT Id,
                                         UserName
                                    FROM User 
                                    WHERE UserName='star.lord@yopmail.com'
                                    LIMIT 1];
                                    
            if(objBorrowerUserList.size() == 1){
                return objBorrowerUserList[0];
            } 
        return null;
    }
    /**
    * @description Method to get application
    * @author Shristy Kumari | 01-06-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                      Dealer_Name__c,
                                                                      Certified_Lender__c
                                                                FROM genesis__Applications__c  
                                                                LIMIT 1];
            if(applicationObjList.size() == 1){
               return applicationObjList[0];
            } 
        return null; 
    }
    /**
    * @description Method to get sales agent account
    * @author Shristy Kumari | 01-06-2025 
    * @return Account 
    **/
    private static Account getSalesAgentAccount(){
        genesis__Applications__c applicationObj = getApplication();
        List<Account> salesAgentAccountObjList = [SELECT Id
                                                        FROM Account  
                                                        WHERE RecordType.Name = 'Sales Agent' 
                                                        AND ParentId =: applicationObj.Dealer_Name__c
                                                        LIMIT 1];
            if(salesAgentAccountObjList.size() == 1){
             return salesAgentAccountObjList[0];
            } 
        return null; 
    }
   
   /**
   * @description Method to test Success Scenerio for Assigning Sales Agent
   * @author Shristy Kumari | 01-08-2025 
   **/
   @isTest
   private static void testAssignSalesAgentSuccess(){
      genesis__Applications__c applicationObj = getApplication();
      Account salesAgentAccountObj = getSalesAgentAccount();
      User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>{
           'applicationId' => applicationObj.id,
           'salesAgent' => salesAgentAccountObj.id,
           'irc' => '0239000',
           'uniqueIdentifier' => '63rf',
           'erpId' => 'Test12345'
        };
        System.runAs(clUserObj){
         Test.startTest();
         PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
         clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),requestMap);
         System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Sales Agent is not assigned successfully');
         List<clcommon__Party__c> updatedPartyList = [SELECT Id,
                                                            genesis__Application__c
                                                     FROM clcommon__Party__c
                                                     WHERE clcommon__Account__c = :salesAgentAccountObj.Id];

            for (clcommon__Party__c updatedParty : updatedPartyList) {
                System.assertEquals(applicationObj.Id, updatedParty.genesis__Application__c,'Sales Agent party should be associated with the application.');
            }
         Test.stopTest();
      }
    }

   /**
   * @description : Method to test exception scenerio for assigning sales agent when application id is null
   * @author Shristy Kumari | 12-31-2024 
   **/
   @isTest
   private static void testNullApplicationIdException(){
        Account salesAgentAccountObj = getSalesAgentAccount();
        Map<String,Object> requestMap = new Map<String,Object>{
            'applicationId' => null,
            'salesAgent' => salesAgentAccountObj.id,
            'irc' => '0239000',
            'erpId' => ''
        };
        User clUserObj = getClUser();
        System.runAs(ClUserObj){
         Test.startTest();
         PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
         clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),requestMap);
         System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Loan details not updated successfully');
            List<clcommon__Log__c> logList = [SELECT Name
                                          FROM clcommon__Log__c 
                                          WHERE Name= 'PortalUpdateLoanDetailsAPI'
                                          LIMIT 1];
         System.assertEquals('PortalUpdateLoanDetailsAPI', logList[0].Name,'Exception Expected');
         Test.stopTest();
        }
    }

   /**
   * @description : Method to test success scenerio for loan detail update with existing sales agent
   * @author Shristy Kumari | 12-31-2024 
   **/
   @isTest
   private static void testWithExistingSalesAgentSuccess(){
       genesis__Applications__c applicationObj = getApplication();
       Account salesAgentAccountObj = getSalesAgentAccount();
       clcommon__Party__c partyObj;
       List<clcommon__Party__c> partyList = [SELECT Id,
                                                genesis__Application__c 
                                            FROM clcommon__Party__c 
                                            WHERE clcommon__Account__c =: salesAgentAccountObj.id];

        for(clcommon__Party__c party : partyList){
            partyObj = party;
            partyObj.genesis__Application__c = applicationObj.id;
        }
        Database.update(partyList,true);
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>{
           'applicationId' => applicationObj.id,
           'salesAgent' => salesAgentAccountObj.id,
           'irc' => '0239000',
           'uniqueIdentifier' => '',
           'erpId' => 'Test12345'
        };
       System.runAs(clUserObj){
          Test.startTest();
          PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
          clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),requestMap);
          System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Loan details updated succesfully with existing sales agent');
          List<clcommon__Party__c> updatedPartyList = [SELECT Id, genesis__Application__c
                                                     FROM clcommon__Party__c
                                                     WHERE clcommon__Account__c = :salesAgentAccountObj.Id];
        
             for (clcommon__Party__c updatedParty : updatedPartyList) {
                 System.assertEquals(applicationObj.Id, updatedParty.genesis__Application__c, 
                'Sales Agent party should be associated with the application.');

             Test.stopTest();
            }
        }
    }
    /**
    * @description : Method to Test exception scenerio to update loan details without Request Map
    * @author Shristy Kumari | 12-31-2024 
    **/
    @isTest
    private static void testWithoutRequestMapException(){
    User clUserObj = getClUser();
        System.runAs(clUserObj){
           Test.startTest();
           PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
           clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),null);
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'failed to test exception scenerio when request map is  missing');
              List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'PortalUpdateLoanDetailsAPI'
                                                LIMIT 1];
           System.assertEquals('PortalUpdateLoanDetailsAPI', logList[0].Name,'Exception Expected');
           Test.stopTest();
        }
    }
   /**
   * @description Method to test Exception scenerio with Blank ERP Id
   * @author Shristy Kumari | 12-31-2024 
   **/
    @isTest
    private static void testWithBlankErpIdException(){
         genesis__Applications__c applicationObj = getApplication();
         Account salesAgentAccountObj = getSalesAgentAccount();
         clcommon__Party__c partyObj;
         List<clcommon__Party__c> partyList = [SELECT Id,
                                                       genesis__Application__c 
                                               FROM clcommon__Party__c 
                                               WHERE clcommon__Account__c =: salesAgentAccountObj.id];

        for(clcommon__Party__c party : partyList){
             partyObj = party;
             partyObj.genesis__Application__c = applicationObj.id;
        }
        Database.update(partyList,true);
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>{
            'applicationId' => applicationObj.id,
            'salesAgent' => salesAgentAccountObj.id,
            'irc' => '0239000',
            'uniqueIdentifier' => '12345',
            'erpId' => ''
        };
        System.runAs(clUserObj){
          Test.startTest();
             PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
             clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),requestMap);
             System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed to test exception scenerio with blank ERP Id');
                List<clcommon__Log__c> logList = [SELECT Name
                                                  FROM clcommon__Log__c 
                                                  WHERE Name= 'PortalUpdateLoanDetailsAPI'
                                                  LIMIT 1];
             System.assertEquals('PortalUpdateLoanDetailsAPI', logList[0].Name,'Exception Expected'); 
          Test.stopTest();
        }
    }
   /**
 * @description : Method to test success scenario when there is no certified Lender associated with the application.
 * @author Shristy Kumari | 12-31-2024 
 **/
@isTest
private static void testUpdateCertifiedLenderSuccess(){
    genesis__Applications__c applicationObj = getApplication();
    Account salesAgentAccountObj = getSalesAgentAccount();
    clcommon__Party__c partyObj;
    
    List<clcommon__Party__c> partyList = [SELECT Id,
                                                 genesis__Application__c 
                                          FROM clcommon__Party__c 
                                          WHERE clcommon__Account__c = :salesAgentAccountObj.Id];
    
    for (clcommon__Party__c party : partyList) {
        partyObj = party;
        partyObj.genesis__Application__c = applicationObj.Id;
    }
    Database.update(partyList, true);
    
    User clUserObj = getClUser();
    Map<String, Object> requestMap = new Map<String, Object> {
        'applicationId' => applicationObj.Id,
        'salesAgent' => salesAgentAccountObj.Id,
        'irc' => '',
        'uniqueIdentifier' => '12345',
        'erpId' => 'Test12345',
        'certifiedLender' => applicationObj.Certified_Lender__c
    };
    System.runAs(clUserObj){
        Test.startTest();
        PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
        clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('', new List<String>(), requestMap);
    
        System.assertEquals(clcommon.Constants.SUCCESS, response.status, 
            'Assertion Failed to test success scenario when there is no certified Lender associated with the application.');        
        List<clcommon__Party__c> updatedPartyList = [SELECT Id, genesis__Application__c
                                                     FROM clcommon__Party__c
                                                     WHERE clcommon__Account__c = :salesAgentAccountObj.Id];
        
        for (clcommon__Party__c updatedParty : updatedPartyList) {
            System.assertEquals(applicationObj.Id, updatedParty.genesis__Application__c, 
                'Sales Agent party should be associated with the application.');
        }
        Test.stopTest();
    }
}

   /**
   * @description : Method to test Success Scenerio when there is no sales agent associated with the application.
   * @author Shristy Kumari | 12-30-2024 
   **/
   @isTest
   private static void testWithoutSaSuccess(){
       genesis__Applications__c applicationObj = getApplication();
       Account salesAgentAccountObj = getSalesAgentAccount();
       clcommon__Party__c partyObj;
       List<clcommon__Party__c> partyList = [SELECT Id,
                                                genesis__Application__c 
                                            FROM clcommon__Party__c 
                                            WHERE clcommon__Account__c =: salesAgentAccountObj.id];

        for(clcommon__Party__c party : partyList){
            partyObj = party;
            partyObj.genesis__Application__c = applicationObj.id;
        }
        Database.update(partyList,true);
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>{
           'applicationId' => applicationObj.id,
           'irc' => '',
           'uniqueIdentifier' => '12345',
           'erpId' => 'Test12345',
           'certifiedLender' =>applicationObj.Certified_Lender__c
        };
        System.runAs(clUserObj){
            Test.startTest();
               PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
               clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),requestMap);
               System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed to test Success Scenerio when there is no sales agent associated with the application');
               List<clcommon__Party__c> updatedPartyList = [SELECT Id, genesis__Application__c
                                                     FROM clcommon__Party__c
                                                     WHERE clcommon__Account__c = :salesAgentAccountObj.Id];
        
            for (clcommon__Party__c updatedParty : updatedPartyList) {
                 System.assertEquals(applicationObj.Id, updatedParty.genesis__Application__c, 
                'Sales Agent party should be associated with the application.');
            }
            Test.stopTest();
        }
    }
    /**
    * @description Method to test Exception Scenerio for unauthorized user
    * @author Shristy Kumari | 01-08-2025 
    **/
    @isTest
    private static void testUnauthorizedUserException(){
    genesis__Applications__c applicationObj = getApplication();
    Account salesAgentAccountObj = getSalesAgentAccount();
    User borrowereUserObj = getBorrowerUser();
         Map<String,Object> requestMap = new Map<String,Object>{
           'applicationId' => applicationObj.id,
           'salesAgent' => salesAgentAccountObj.id,
           'irc' => '0239000',
           'uniqueIdentifier' => '63rf',
           'erpId' => 'Test12345'
        };
        System.runAs(borrowereUserObj){
          Test.startTest();
          PortalUpdateLoanDetailsAPI portalUpdateLoanDetApiObj = new PortalUpdateLoanDetailsAPI();
          clcommon.Response response = portalUpdateLoanDetApiObj.invokeAction('',new List<String>(),requestMap);
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Exception expected');
                List<clcommon__Log__c> logList = [SELECT Name
                                                  FROM clcommon__Log__c 
                                                  WHERE Name= 'PortalUpdateLoanDetailsAPI'
                                                  LIMIT 1];
          System.assertEquals('PortalUpdateLoanDetailsAPI', logList[0].Name,'Exception Expected'); 
          Test.stopTest();
        }
    }
}