/**
 * @description       : Test class for Portal Update Grower Parent API
 * @author            : Shruti Tamakhuwala
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Shruti Tamakhuwala
**/
@isTest
private without sharing class PortalUpdateGrowerParentAPITest {
    /**
    * @description This method is used to create test data
    **/
    @TestSetup
    static void makeData(){
        Integer count;
        Integer tin = 666899905;
        List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>();
        List<Account> dealerAccountList = new List<Account>();
        List<Dealer_Applicant_Relationship__c> dealerAppRelationList = new List<Dealer_Applicant_Relationship__c>();

        // Creating Business Information for Dealer, Borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        businessInfoList.add(borrowerBusinessInfoObj);
        for(count=0;count<4;count++){
            genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
            dealerBusinessInfoObj.genesis__Tax_Identification_Number__c = String.valueOf(tin + 100);
            businessInfoList.add(dealerBusinessInfoObj);
        }
        Database.insert(businessInfoList,true);
        // Creating Accounts of Dealers for CFA and Growmark coop types
        for(count=0;count<4;count++){
            Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoList[count+1].Id);
            if(count>1){
                dealerAccountObj.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            }
            dealerAccountList.add(dealerAccountObj);
        }
        Database.insert(dealerAccountList,true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj,true);
        //Creating a borrower and Certified Lender accounts with Gray label type dealer as ParentId
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(null, dealerAccountList[0].Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, businessInfoList[0].Id,dealerAccountList[0].Id);
        Database.insert(new List<Account>{
            clAccountObj,
            borrowerAccountObj
        },true);
        // Creating Contact for Certified Lender, Borrower
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{
                                            clContactObj,
                                            borrowerContactObj
                                        },true);
        // Creating User for Certified Lender, Borrower
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{
                                        clUserObj,
                                        borrowerUserObj
                                    },true);
        // Creating Dealer Applicant Relationship for differnt dealers
        for(Account accountObj: dealerAccountList){
            Dealer_Applicant_Relationship__c dealerAppRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,accountObj.Id);
            dealerAppRelationList.add(dealerAppRelationObj);
        }
        Database.insert(dealerAppRelationList,true);             
    }

    /**
    * @description This method is used to get User to run test
    * @author Shruti Tamakhuwala | 01-16-2025 
    * @param userAccountName 
    * @return User 
    **/
    private static User getUser(String userAccountName){
        List<User> userList = [SELECT Id,
                                        Account.Name,
                                        Profile.Name
                                FROM User
                                WHERE Account.Name =: userAccountName 
                                AND isActive = true  
                                LIMIT 1];
        if(!userList.isEmpty()) {
            return userList[0];
        }     
        return null;
    } 

    /**
    * @description This method is used to get Borrower Account
    * @author Shruti Tamakhuwala | 01-16-2025 
    * @return Account 
    **/
    private static Account getGrowerAccount(){
        List<Account> accountList = [SELECT Id, 
                                                Name,
                                                ParentId,
                                                Parent.Coop_Type__c,
                                                RecordType.Name
                                        FROM Account
                                        WHERE Name = 'Jasmine Albin'
                                        LIMIT 1];
        if(!accountList.isEmpty()){
            return accountList[0];
        }          
        return null;
    }

    /**
    * @description This method is used to get Dealer Applicant Relationship records of the grower of a coop type
    * @author Shruti Tamakhuwala | 01-20-2025 
    * @param growerAccountId 
    * @param coopType 
    * @return List<Dealer_Applicant_Relationship__c>
    **/
    private static List<Dealer_Applicant_Relationship__c> getDealerRelations(String growerAccountId, String coopType){
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = [SELECT Id, 
                                                                                Dealer__c,
                                                                                Dealer__r.Coop_Type__c,
                                                                                Applicant__c
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        WHERE Applicant__c = :growerAccountId
                                                                        AND Dealer__r.Coop_Type__c = :coopType
                                                                        ORDER BY CreatedDate DESC
                                                                        LIMIT 2
                                                                        ];
        if(!dealerRelationsList.isEmpty()){
            return dealerRelationsList;
        }
        return null;
    }

    /**
    * @description This method is used to get log message name
    * @author Shruti Tamakhuwala | 01-20-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getLogMessage(){
        List<clcommon__Log__c> logList = [SELECT Name,
                                                    clcommon__Message__c
                                            FROM clcommon__Log__c
                                            WHERE Name = 'PortalUpdateGrowerParentAPI'
                                            LIMIT 1];
        if(!logList.isEmpty()){
            return logList;
        }           
        return null;
    }

    /**
    * @description This method is used to test success if the grower’s parent account is updated successfully when the coop type is switching from "Gray Label" to "White Label"
    * @author Shruti Tamakhuwala | 01-16-2025 
    **/
    @isTest
    private static void testGmkParentUpdateSuccess(){
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'wl_grower'});
            System.assertEquals(ConstantValues.GROWMARK_COOP_TYPE, getGrowerAccount().Parent.Coop_Type__c, 'Updated grower should have parent of Growmark type');   
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for switching from Gray Label to White Label');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test success if the grower’s parent account is updated successfully when the coop type is switching from "White Label" to "Gray Label"
    * @author Shruti Tamakhuwala | 01-17-2025 
    **/
    @isTest
    private static void testGrayLabelParentUpdateSuccess(){
        Account growerAccountObj = getGrowerAccount();
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.GROWMARK_COOP_TYPE);
        growerAccountObj.ParentId = dealerRelationsList[0].Dealer__c;
        Database.update(growerAccountObj,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            System.assertEquals(ConstantValues.CFA_COOP_TYPE, getGrowerAccount().Parent.Coop_Type__c, 'Updated grower should have parent of Gray Lable type');    
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for switching from White Label to Gray Label');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test success if the grower’s parent account is not updated when the coop type is not switching from "Gray Label"
    * @author Shruti Tamakhuwala | 01-17-2025 
    **/
    @isTest
    private static void testNoSwitchingfromGlSuccess(){
        Account growerAccountObj = getGrowerAccount();
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            System.assertEquals(growerAccountObj.ParentId, getGrowerAccount().ParentId, 'No update on grower parentId should happen when no swithching on coop type');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for no switching from Gray Label');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test success if the grower’s parent account is not updated when the coop type is not switching from "White Label"
    * @author Shruti Tamakhuwala | 01-17-2025 
    **/
    @isTest
    private static void testNoSwitchingfromGmkSuccess(){
        Account growerAccountObj = getGrowerAccount();
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.GROWMARK_COOP_TYPE);
        growerAccountObj.ParentId = dealerRelationsList[0].Dealer__c;
        Database.update(growerAccountObj,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'wl_grower'});
            System.assertEquals(growerAccountObj.ParentId, getGrowerAccount().ParentId, 'No update on grower parentId should happen when no swithching on coop type');    
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for no switching from White Label');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test success if Certified Lender is logging to portal
    * @author Shruti Tamakhuwala | 01-17-2025 
    **/
    @isTest
    private static void testClLoginSuccess(){
        System.runAs(getUser('Ross Geller')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for no switching from Gray Label');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test standard exception thrown when no parent account is present on the grower account
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testMissingParentIdException(){
        Account growerAccountObj = getGrowerAccount();
        growerAccountObj.ParentId = null;
        Database.update(growerAccountObj,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            List<clcommon__Log__c> logList = getLogMessage();
            System.assertEquals(1, logList.size(), 'Exception Expected when Grower has no Parent');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Exception Expected when Grower has no Parent');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test standard exception thrown when for a grower, parent coop type is null
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testMissingParentCoopTypeSuccess(){
        Account growerAccountObj = getGrowerAccount();
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.GROWMARK_COOP_TYPE);
        growerAccountObj.ParentId = dealerRelationsList[0].Dealer__c;
        Database.update(growerAccountObj,true);
        List<Account> dealerAccount = [SELECT ID,
                                                Coop_Type__c
                                        FROM Account
                                        WHERE ID =: growerAccountObj.ParentId
                                        LIMIT 1];        
        dealerAccount[0].Coop_Type__c = null;
        Database.update(dealerAccount[0],true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            System.assertEquals(1, getLogMessage().size(), 'Exception Expected when parent coop type is null');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Exception expected when parent coop type is null');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test standard exception thrown when null is passed as community name in request map
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testInvalidCommunityNameException(){
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => null});
            List<clcommon__Log__c> logList = getLogMessage();
            System.assertEquals(1, logList.size(), 'Exception expected when community name is null in request map');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Exception expected when community name is null in request map');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test standard exception when no request map is passed
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testMissingRequestMapException(){
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, null);
            System.assertEquals(1, getLogMessage().size(), 'Exception expected when request map is null');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Exception expected when request map is null');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test custom exception when no account for user is present
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testMissingAccountException(){
        List<User> userList = [SELECT Id
                                FROM USER 
                                WHERE Profile.Name =: ConstantValues.PROFILE_ADMIN
                                AND IsActive = true 
                                ORDER BY CreatedDate ASC 
                                LIMIT 1];
    System.runAs(userList[0]){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            System.assertEquals(1, getLogMessage().size(), 'Custom Exception expected for missing grower account');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Custom Exception expected missing grower account');  
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test Custom Exception when the dealer applicant relationship is not present for White Label type
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testMissingWlCoopTypeInDealerRelationException(){
        List<Account> updatedDealerList  = new List<Account>();
        Account growerAccountObj = getGrowerAccount();
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.GROWMARK_COOP_TYPE);
        for(Dealer_Applicant_Relationship__c dealerRelationsObj: dealerRelationsList){
            dealerRelationsObj.Dealer__r.Coop_Type__c = null;
            updatedDealerList.add(dealerRelationsObj.Dealer__r);
        }
        Database.update(updatedDealerList,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'wl_grower'});
            System.assertEquals(1, getLogMessage().size(), 'Custom Exception expected when invalid dealer coop type present in dealer applicant relation for the grower for white label type');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Custom Exception expected when invalid dealer coop type present in dealer applicant relation for the grower for white label type');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test custom exception when there is no dealer in dealer applicant relationship for White Label type
    * @author Shruti Tamakhuwala | 01-20-2025 
    **/
    @isTest
    private static void testMissingWlDealerInDealerRelationException(){
        List<Dealer_Applicant_Relationship__c> updatedDealerRelationList  = new List<Dealer_Applicant_Relationship__c>();
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(getGrowerAccount().Id, ConstantValues.GROWMARK_COOP_TYPE);
        for(Dealer_Applicant_Relationship__c dealerRelationsObj: dealerRelationsList){
            dealerRelationsObj.Dealer__c = null;
            updatedDealerRelationList.add(dealerRelationsObj);
        }
        Database.update(updatedDealerRelationList,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'wl_grower'});
            System.assertEquals(1, getLogMessage().size(), 'Custom Exception expected when dealer of white label type is missing in dealer applicant relation for the grower');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Custom Exception expected when when dealer of white label type is missing in dealer applicant relation for the grower');  
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test custom exception when there is no dealer in dealer applicant relationship for Gray Label type
    * @author Shruti Tamakhuwala | 01-21-2025 
    **/
    @isTest
    private static void testMissingGlDealerInDealerRelationException(){
        Account growerAccountObj = getGrowerAccount();
        List<Dealer_Applicant_Relationship__c> gmkDealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.GROWMARK_COOP_TYPE);
        growerAccountObj.ParentId = gmkDealerRelationsList[0].Dealer__c;
        Database.update(growerAccountObj,true);
        List<Dealer_Applicant_Relationship__c> updatedDealerRelationList  = new List<Dealer_Applicant_Relationship__c>();
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(getGrowerAccount().Id, ConstantValues.CFA_COOP_TYPE);
        for(Dealer_Applicant_Relationship__c dealerRelationsObj: dealerRelationsList){
            dealerRelationsObj.Dealer__c = null;
            updatedDealerRelationList.add(dealerRelationsObj);
        }
        Database.update(updatedDealerRelationList,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            System.assertEquals(1, getLogMessage().size(), 'Custom Exception expected when dealer of gray label type is missing in dealer applicant relation for the grower');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Custom Exception expected when when dealer of gray label type is missing in dealer applicant relation for the grower');  
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test Custom Exception when the dealer applicant relationship is not present for Gray Label type
    * @author Shruti Tamakhuwala | 01-21-2025 
    **/
    @isTest
    private static void testMissingGlCoopTypeInDealerRelationException(){
        List<Account> updatedDealerList  = new List<Account>();
        Account growerAccountObj = getGrowerAccount();
        List<Dealer_Applicant_Relationship__c> gmkDealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.GROWMARK_COOP_TYPE);
        growerAccountObj.ParentId = gmkDealerRelationsList[0].Dealer__c;
        Database.update(growerAccountObj,true);
        List<Dealer_Applicant_Relationship__c> dealerRelationsList = getDealerRelations(growerAccountObj.Id, ConstantValues.CFA_COOP_TYPE);
        for(Dealer_Applicant_Relationship__c dealerRelationsObj : dealerRelationsList){
            dealerRelationsObj.Dealer__r.Coop_Type__c = null;
            updatedDealerList.add(dealerRelationsObj.Dealer__r);
        }
        Database.update(updatedDealerList,true);
        System.runAs(getUser('Jasmine Albin')){
            Test.startTest();
            //Calling the API
            clcommon.Response response = new PortalUpdateGrowerParentAPI().invokeAction('', null, new Map<String, Object>{'community_name' => 'gl_grower'});
            System.assertEquals(1, getLogMessage().size(), 'Custom Exception expected when invalid dealer coop type present in dealer applicant relation for the grower for gray label type');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Custom Exception expected when invalid dealer coop type present in dealer applicant relation for the grower for gray label type');
            Test.stopTest();
        }
    }
}