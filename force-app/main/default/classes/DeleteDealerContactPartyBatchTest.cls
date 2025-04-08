/**
 * @description       : 
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 04-16-2024
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public with sharing class DeleteDealerContactPartyBatchTest {
    @TestSetup
    static void makeData(){
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);
        // Creating Account for Dealer
        Account gmkDealerAccountObj = TestClassHelper.createGMKDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(gmkDealerAccountObj, true);

        // creating Account for Certified Lender
        Account fsAccountObj = TestClassHelper.createFSAgentAccount(dealerBusinessInfoObj.Id, gmkDealerAccountObj.Id);
        Database.insert(fsAccountObj, true);

        // Creating Contact for Certified Lender
        Contact fsContactObj = TestClassHelper.createFSAgentContact(fsAccountObj.Id);
        Database.insert(fsContactObj, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c fsRoleObj = TestClassHelper.createReciprocalRole('Field Staff Agent');
        Database.insert(fsRoleObj, true);
        clcommon__Relationship__c fsRelationship = TestClassHelper.createCLDealerRelationship(fsRoleObj, 
                                                                                                    gmkDealerAccountObj.Id, 
                                                                                                    fsAccountObj.Id);
        Database.insert(fsRelationship, true);

        // Creating Field Staff Agent Party Type
        clcommon__Party_Type__c fsPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('FIELD STAFF AGENT');
        Database.insert(fsPartyTypeObj, true);

        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAdminAccObj, true);
 
        //createing sa admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);

        //creating a sales agent 
        Account saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(saAccObj, true);
  
        //createing sa contact
        Contact saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        Database.insert(saContactObj, true);

        // Creating Sales Agent User
        User saUser = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        Database.insert(saUser, true);

        //creating related sales agent  role
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        Database.insert(rsaRoleObj, true);

        //creating related sales agent  relationship
        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccObj.Id);
        Database.insert(relationshipObject, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // creating application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String, Id>{'dealerAccountId' => dealerAccountObj.Id,
                                                                                                                                        'clProductId' => clProductObj.Id,
                                                                                                                                        'clPurposeId' => clPurposeObj.Id,
                                                                                                                                        'borrowerAccountId' => null,
                                                                                                                                        'borrowerContactId' => null,
                                                                                                                                        'clAccountId' => clAccountObj.Id});
        applicationObj.Sales_Agent__c = saAccObj.Id;
        Database.insert(applicationObj, true);

         // Creating Certified Lender Party Type
         clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
         Database.insert(clPartyTypeObj, true);


        // Creating Sales Agent Party Type
        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        Database.insert(saPartyTypeObj, true);

          // Creating Sales Agent Admin Party Type
        clcommon__Party_Type__c saAdminPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        Database.insert(saAdminPartyTypeObj, true);


        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>{ApplicationOriginationTestHelper.createParty(new Map<String, Id>{'accountId' => saAdminAccObj.Id,
                                                                                                                                            'contactId' => saAdminContactObj.Id,
                                                                                                                                            'partyTypeId' => saAdminPartyTypeObj.Id,
                                                                                                                                            'applicationId'=> applicationObj.Id}),
                                                                            ApplicationOriginationTestHelper.createParty(new Map<String, Id>{'accountId' => saAccObj.Id,
                                                                                                                                            'contactId' => saContactObj.Id,
                                                                                                                                            'partyTypeId' => saPartyTypeObj.Id,
                                                                                                                                            'applicationId'=> applicationObj.Id}),
                                                                            ApplicationOriginationTestHelper.createParty(new Map<String, Id>{'accountId' => clAccountObj.Id,
                                                                                                                                            'contactId' => clContactObj.Id,
                                                                                                                                            'partyTypeId' => clPartyTypeObj.Id,
                                                                                                                                            'applicationId'=> applicationObj.Id})};
        Database.insert(partyList, true);
    }
     /**
    * @description Get Account From Name.
    * @author Ayan Bhowmik | 04-14-2024 
    * @param name 
    * @return Account 
    **/
    private static Account getAccount(String name) {
        return [SELECT Id,
                    ParentId
                FROM Account
                WHERE Name =: name
                LIMIT 1];
    }

    @IsTest
    private static void testCaseSucces() {
        Account dealerAccount = getAccount('Kisan Loan');
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c
                                                            WHERE Dealer_Name__c = :dealerAccount.Id 
                                                            LIMIT 1];
        Account accountObj = getAccount('Ross Geller');
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj){
            Test.startTest();
            DeleteDealerContactPartyBatch deleteDealerContactParty = new DeleteDealerContactPartyBatch(new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => accountObj.Id,
                                                                                                                                ConstantValues.PREVIOUS_DEALER_ID => dealerAccount.Id,
                                                                                                                                ConstantValues.PREVIOUS_RECORD_TYPE_NAME => new List<String>{'Certified Lender'},
                                                                                                                                ConstantValues.UPDATE_RECORD => true
            });
            Database.executeBatch(deleteDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));
            Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationList[0].Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Certified Lender' 
                                                LIMIT 1];
        System.assertEquals(0, partyObj.size(), 'Party Deletion Failed');
        applicationList = [SELECT Id,
                                Certified_Lender__c
                            FROM genesis__Applications__c
                            WHERE Dealer_Name__c = :dealerAccount.Id 
                            LIMIT 1];
        System.assertEquals(null, applicationList[0].Certified_Lender__c, 'Application CL Change Failed');
    }
    @IsTest
    private static void testCaseSuccesForSA() {
        List<Id> saAdminAccountIdList = new List<Id>();
        Account dealerAccount = getAccount('Kisan Loan');
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c
                                                            WHERE Dealer_Name__c = :dealerAccount.Id 
                                                            LIMIT 1];
        Account accountObj = getAccount('Tony Stark');
        List<clcommon__Relationship__c> relatedSAList = [SELECT Id, 
                                                                clcommon__Entity__c, 
                                                                clcommon__Related_Entity__c, 
                                                                clcommon__Relationship__c 
                                                            FROM clcommon__Relationship__c 
                                                            WHERE clcommon__Related_Entity__c =: accountObj.Id 
                                                            AND clcommon__Relationship__r.Name =: 'Related Sales Agent'];
        for(clcommon__Relationship__c rel: relatedSAList){
            saAdminAccountIdList.add(rel.clcommon__Entity__c);
        }
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj){
            Test.startTest();
            DeleteDealerContactPartyBatch deleteDealerContactParty = new DeleteDealerContactPartyBatch(new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => accountObj.Id,
                                                                                                                                ConstantValues.PREVIOUS_DEALER_ID => dealerAccount.Id,
                                                                                                                                ConstantValues.PREVIOUS_RECORD_TYPE_NAME => new List<String>{'Sales Agent'},
                                                                                                                                ConstantValues.UPDATE_RECORD => true,
                                                                                                                                ConstantValues.SALES_AGENT_ADMIN_RELATIONSHIP => saAdminAccountIdList
            });
            Database.executeBatch(deleteDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));
            Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationList[0].Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Sales Agent' 
                                                LIMIT 1];
        System.assertEquals(0, partyObj.size(), 'SA Party Deletion Failed');
        List<clcommon__Party__c> saAdminpartyObj = [SELECT Id
                                                        FROM clcommon__Party__c 
                                                        WHERE genesis__Application__c =: applicationList[0].Id 
                                                        AND clcommon__Account__r.RecordType.Name = 'Sales Agent Admin' 
                                                        LIMIT 1];
        System.assertEquals(0, saAdminpartyObj.size(), 'SA Admin Party Deletion Failed');
        applicationList = [SELECT Id,
                                Sales_Agent__c
                            FROM genesis__Applications__c
                            WHERE Dealer_Name__c = :dealerAccount.Id 
                            LIMIT 1];
        System.assertEquals(null, applicationList[0].Sales_Agent__c, 'Application SA Change Failed');
    }
    @IsTest
    private static void testCaseSuccesForFSA() {
        Account dealerAccount = getAccount('Kisan Loan');
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c
                                                            WHERE Dealer_Name__c = :dealerAccount.Id 
                                                            LIMIT 1];
        Account accountObj = getAccount('Ross FieldStaff');
        Contact contactObj = [SELECT Id, 
                                    AccountId
                                FROM Contact
                                WHERE AccountId =: accountObj.Id];
        // Creating Sales Agent User
        User fsaUser = ApplicationOriginationTestHelper.createFSAgentUser(contactObj.Id);
        Database.insert(fsaUser, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj){
            Test.startTest();
            DeleteDealerContactPartyBatch deleteDealerContactParty = new DeleteDealerContactPartyBatch(new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => accountObj.Id,
                                                                                                                                ConstantValues.PREVIOUS_DEALER_ID => dealerAccount.Id,
                                                                                                                                ConstantValues.PREVIOUS_RECORD_TYPE_NAME => new List<String>{'Field Staff Agent'},
                                                                                                                                ConstantValues.UPDATE_RECORD => true,
                                                                                                                                ConstantValues.RECORD_TYPE_NAME => new List<String>{'Inquiry Plus'}
            });
            Database.executeBatch(deleteDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));
            Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationList[0].Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Field Staff Agent' 
                                                LIMIT 1];
        System.assertEquals(0, partyObj.size(), 'Party Deletion Failed');
    }
}