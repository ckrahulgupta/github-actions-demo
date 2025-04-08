/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
**/
@IsTest
private with sharing class DeleteSalesAgentAdminPartyBatchTest {
    /**
    * @description : This test ethod is used to prepare the test data
    * @author Ayan Khanra | 01-12-2025 
    **/
    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup(); 
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    Name,
                                                                    CreatedById,
                                                                    CreatedBy.Account.Name, 
                                                                    Internal_Reference_Code__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Internal_Reference_Code__c ='testApp001'];          
        List<Account> dealerAccountObjList = [SELECT ID,
                                                        Name, 
                                                        genesis__Business_Information__c 
                                                FROM Account 
                                                WHERE Name='Kisan Loan'];
        List<Account> saAdminAccountObjList = [SELECT ID,
                                                        Name 
                                                FROM Account 
                                                WHERE Name = 'Henry Yates'];
        List<Contact> saAdminContactObjList = [SELECT ID,
                                                        FirstName ,
                                                        LastName
                                                FROM Contact 
                                                WHERE AccountId =:saAdminAccountObjList[0].Id];
        //createOwner(applicationObjList);
        createSalesAgentAdminuser(saAdminAccountObjList[0],saAdminContactObjList[0]);
        createAnotherSalesAgent(dealerAccountObjList[0],saAdminAccountObjList[0]);
        clcommon__Party_Type__c partyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        Database.insert(partyTypeObj, true);
        Map<String,Id> objectVsIdMap=new Map<String,Id>();
        objectVsIdMap.put('accountId',saAdminAccountObjList[0].Id);
        objectVsIdMap.put('contactId',saAdminContactObjList[0].Id);
        objectVsIdMap.put('partyTypeId',partyTypeObj.Id);
        objectVsIdMap.put('applicationId',applicationObjList[0].Id);
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(objectVsIdMap);
        Database.insert(partyObj, true);
    }


    /**
    * @description 
    * @author Ayan Khanra | 12-21-2024 
    * @param saAdminAccountObj 
    * @param saAdminContactObj 
    **/
    private static void createSalesAgentAdminuser(Account saAdminAccountObj,Contact saAdminContactObj){
        saAdminContactObj.FirstName='Henry';
        saAdminContactObj.LastName='Yates';
        Database.update(saAdminContactObj);
        User saAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        saAdminUserObj.LastName='Yates';
        saAdminUserObj.Email='henry.yates@yopmail.com';
        saAdminUserObj.UserName='henry.yates@yopmail.com';
        Database.insert(saAdminUserObj);
    }

    /**
    * @description 
    * @author Ayan Khanra | 12-21-2024 
    * @param dealerAccountObj 
    * @param saAdminAccountObj
    **/
    private static void createAnotherSalesAgent(Account dealerAccountObj,Account saAdminAccountObj){
        Account saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerAccountObj.genesis__Business_Information__c,dealerAccountObj.Id);
        saAccObj.Name = 'Robert Brown';
        saAccObj.Phone = '993211590';
        saAccObj.CIF_Number__c = '000988';
        saAccObj.clcommon__Email__c = 'robert.brown@yopmail.com';
        Database.insert(saAccObj, true);
        //contact another sales agent
        Contact saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        saContactObj.FirstName='Robert';
        saContactObj.LastName='Brown';
        saContactObj.Email='robert.brown@yopmail.com';
        saContactObj.Phone='993211590';
        Database.insert(saContactObj, true);
        //creating another sales agent
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        saUserObj.Email='robert.brown@yopmail.com';
        saUserObj.UserName='robert.brown@yopmail.com';
        Database.insert(saUserObj, true);

        List<clcommon__Reciprocal_Role__c> relateSalesAgentList = [SELECT ID,
                                                                            Name 
                                                                    FROM clcommon__Reciprocal_Role__c 
                                                                    WHERE Name =:PortalConstants.RELATED_SALES_AGENT];
        clcommon__Relationship__c saaRelationshipWithSaList = ApplicationOriginationTestHelper.createCLDealerRelationship(relateSalesAgentList[0],saAdminAccountObj.Id,saAccObj.Id);
        Database.insert(saaRelationshipWithSaList);
    }

    /**
    * @description : This test method deletes the party of sales agent admin
    * @author Ayan Khanra | 12-21-2024 
    **/
    @IsTest
    private static void checkForPartyDeletion(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                        Name, 
                                                                        Internal_Reference_Code__c,
                                                                        CreatedBy.AccountId
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c ='testApp001'];                                                              
        List<Account> saAccountList = [SELECT Id,
                                            Name 
                                        FROM Account 
                                        WHERE Name In('Robert Brown','Tony Stark')];
        List<Account> saAdminAccountList = [SELECT Id,
                                                    Name 
                                            FROM Account 
                                            WHERE Name = 'Henry Yates'];
        List<Id> salesAgentAccountIdList = new List<Id>();
        for(Account accountObj : saAccountList){
            salesAgentAccountIdList.add(accountObj.Id);
        }
        User systemAdminuserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemAdminuserObj){
            Test.startTest();
            DeleteSalesAgentAdminPartyBatch batchInstance = new DeleteSalesAgentAdminPartyBatch(salesAgentAccountIdList,saAdminAccountList[0].Id);
            Database.executeBatch(batchInstance);
            Test.stopTest();
            List<clcommon__Party__c> newPartyObj = [SELECT Id,
                                                            Name,
                                                            genesis__Application__c 
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Account__r.Id =: saAdminAccountList[0].Id
                                                    AND genesis__Application__c = : applicationObjList[0].Id];
            System.assertEquals(0,newPartyObj.size(),'Party not deleted');    
        }      
    }
}