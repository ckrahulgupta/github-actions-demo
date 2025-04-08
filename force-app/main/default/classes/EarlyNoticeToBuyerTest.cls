/**
 * @description       : Test class for EarlyNoticeToBuyer
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Shruti Tamakhuwala
**/

@isTest
private with sharing class EarlyNoticeToBuyerTest {
    /**
    * @description Creating Test Data
    **/
    @TestSetup
    static void makeData(){
        // Creating Business Information for Dealer, Borrower
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{ 
                                                                    dealerBusinessInfoObj,
                                                                    borrowerBusinessInfoObj
                                                                },true);
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj,true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj,true);        
        // Creating Account for Certified Lender, Borrower, Buyer
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(null, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id,dealerAccountObj.Id);
        Account buyerAccountObj = ApplicationOriginationTestHelper.createBuyerAccount(entityObj, null);
        Database.insert(new List<Account>{
                                        clAccountObj,
                                        borrowerAccountObj,
                                        buyerAccountObj
                                    },true);
        // Creating Contact for Certified Lender, Borrower, Buyer
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact buyerContactObj = ApplicationOriginationTestHelper.createBuyerContact(buyerAccountObj.Id);
        Database.insert(new List<Contact>{
                                        clContactObj,
                                        borrowerContactObj,
                                        buyerContactObj
                                    },true);
        // Creating User for Certified Lender, Borrower
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{
                                        clUserObj,
                                        borrowerUserObj
                                    },true);
        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);
        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
                                                                    'dealerAccountId' => dealerAccountObj.Id,
                                                                    'clProductId' => clProductObj.Id,
                                                                    'clPurposeId' => clPurposeObj.Id,
                                                                    'borrowerAccountId' => borrowerAccountObj.Id,
                                                                    'borrowerContactId' => borrowerContactObj.Id,
                                                                    'clAccountId' =>  clAccountObj.Id
                                                                };
        // Creating Current Crop Year Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj,true);
        // Creating Party Type for Certified Lender, Borrower, Buyer
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        clcommon__Party_Type__c buyerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BUYER_PARTY_NAME);
        Database.insert(new List<clcommon__Party_Type__c>{
                                                            clPartyTypeObj,
                                                            borrowerPartyTypeObj,
                                                            buyerPartyTypeObj
                                                        },true);
        // Creating Party for Certified Lender
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
                                                                'accountId' => clAccountObj.Id,
                                                                'contactId' => clContactObj.Id,
                                                                'partyTypeId' => clPartyTypeObj.Id,
                                                                'applicationId' => applicationObj.Id
                                                            };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        // Creating Party for Borrower
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
                                                                    'accountId' => borrowerAccountObj.Id,
                                                                    'contactId' => borrowerContactObj.Id,
                                                                    'partyTypeId' => borrowerPartyTypeObj.Id,
                                                                    'applicationId' => applicationObj.Id
                                                                };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        // Creating Party for Buyer
        Map<String,Id> paramForBuyerPartyMap = new Map<String,Id>{
                                                                    'accountId' => buyerAccountObj.Id,
                                                                    'contactId' => buyerContactObj.Id,
                                                                    'partyTypeId' => buyerPartyTypeObj.Id,
                                                                    'applicationId' => applicationObj.Id
                                                                };
        clcommon__Party__c buyerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBuyerPartyMap);
        Database.insert(new  List<clcommon__Party__c>{
                                                        clPartyObj,
                                                        borrowerPartyObj,
                                                        buyerPartyObj
                                                    },true);
        // Creating DealerApplicant Relationship
        Dealer_Applicant_Relationship__c dealerAppRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(dealerAppRelationObj,true);        
        // Creating required task to complete
        Task taskObj = ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Notice of Security Interest (CFA Action)');
        taskObj.Status='Completed';
        Database.insert(taskObj,true);       
    }

    /**
    * @description This method is used to get User to run test
    * @author Shruti Tamakhuwala | 01-08-2025 
    * @param profileName 
    * @return User 
    **/
    private static User getUser(String profileName){
        List<User> userList = [SELECT Id
                                FROM USER 
                                WHERE Profile.Name =: profileName 
                                AND IsActive = true 
                                ORDER BY CreatedDate ASC 
                                LIMIT 1];
        if (!userList.isEmpty()){
            return userList[0];
        }
        return null;
    }

    /**
    * @description This method is used to get parties in application
    * @author Shruti Tamakhuwala | 01-08-2025 
    * @return clcommon__Party__c 
    **/
    private static List<clcommon__Party__c> getParty(){
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    NTB_Generated__c,
                                                    Name  
                                            FROM clcommon__Party__c 
                                            WHERE clcommon__Account__r.Name = 'Jacota Morgan'
                                            LIMIT 1];
        if(!partyList.isEmpty()){
            return partyList;
        }
        return null;
    }

    /**
    * @description : success scenario for early notice to buyer
    * @author Simran | 08-12-2024 
    **/
    @isTest
    private static void testSuccessScenarioEarlyNTB(){
        System.runAs(new User(Id = UserInfo.getUserId())){ 
            Test.startTest();
            EarlyNoticeToBuyers.earlyNotices(EarlyNoticeToBuyerTest.getParty());
            List<clcommon__party__c> updatedPartyList = EarlyNoticeToBuyerTest.getParty();
            System.assertEquals(true, updatedPartyList[0].NTB_Generated__c, 'NTB_Generated__c should be true if Early Notice To Buyer is generated');
            Test.stopTest();
        }
    }

    /**
    * @description : failure scenario for early notice to buyer- empty partylist passed as parameter
    * @author Simran | 08-12-2024 
    **/
    @isTest
    private static void testFailureScenarioEarlyNTB(){
        List<clcommon__party__c> partyList;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest(); 
            EarlyNoticeToBuyers.earlyNotices(partyList);
            List<clcommon__Log__c> logList= [SELECT Id,
                                                    Name
                                            FROM clcommon__Log__c
                                            WHERE Name = 'EarlyNoticeToBuyers' 
                                            LIMIT 1];
            System.assertEquals(1,logList.size(), 'Exception Expected');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check CFA Admin User Access Success
    * @author Shruti Tamakhuwala | 01-08-2025 
    **/
    @isTest
    private static void testCFAAdminUserAccessSuccess(){      
        User userObj = EarlyNoticeToBuyerTest.getUser(ConstantValues.PROFILE_CFA_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            EarlyNoticeToBuyers.earlyNotices(EarlyNoticeToBuyerTest.getParty());
            List<clcommon__party__c> updatedPartyList = EarlyNoticeToBuyerTest.getParty();
            System.assertEquals(true, updatedPartyList[0].NTB_Generated__c, 'NTB_Generated__c should be true if Early Notice To Buyer is generated');
            Test.stopTest();
        }        
    }
}