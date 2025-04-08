/**
 * @description       : Test Class for GenerateNTBSummaryLabels 
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Shruti Tamakhuwala
**/

@isTest
private with sharing class TestNTBSummaryLabels {
    /**
    * @description - Creating Test Data
    **/
    @TestSetup
    static void makeData(){
        Map<String,Id> objectVsIdMap = new Map<String,Id>();
        String ntbName = 'NTB Labels(Buyer'+'\''+'s Name - '+'Jacota Morgan'+').pdf';
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
        borrowerAccountObj.Score_1__c = '564';
        borrowerAccountObj.SBSS70_Score__c = '78';
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
        Database.insert(clPurposeObj,true);
        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        // Creating map for Application
        objectVsIdMap = new Map<String,Id>{
                                            'dealerAccountId' => dealerAccountObj.Id,
                                            'clProductId' => clProductObj.Id,
                                            'clPurposeId' => clPurposeObj.Id,
                                            'borrowerAccountId' => borrowerAccountObj.Id,
                                            'borrowerContactId' => borrowerContactObj.Id,
                                            'clAccountId' =>  clAccountObj.Id
                                        };
        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(objectVsIdMap);
        Database.insert(applicationObj,true);
        // Creating Party Type for Certified Lender, Borrower, Buyer
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        clcommon__Party_Type__c buyerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BUYER_PARTY_NAME);
        Database.insert(new List<clcommon__Party_Type__c>{
                                                            clPartyTypeObj,
                                                            borrowerPartyTypeObj,
                                                            buyerPartyTypeObj
                                                        }, true);
        //Creating Party for Certified Lender
        objectVsIdMap = new Map<String,Id>{
                                            'accountId' => clAccountObj.Id,
                                            'contactId' => clContactObj.Id,
                                            'partyTypeId' => clPartyTypeObj.Id,
                                            'applicationId' => applicationObj.Id
                                        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(objectVsIdMap);
        //Creating Party for Borrower
        objectVsIdMap = new Map<String,Id>{
                                            'accountId' => borrowerAccountObj.Id,
                                            'contactId' => borrowerContactObj.Id,
                                            'partyTypeId' => borrowerPartyTypeObj.Id,
                                            'applicationId' => applicationObj.Id
                                        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(objectVsIdMap);
        //Creating Party for Buyer
        objectVsIdMap = new Map<String,Id>{
                                            'accountId' => buyerAccountObj.Id,
                                            'contactId' => buyerContactObj.Id,
                                            'partyTypeId' => buyerPartyTypeObj.Id,
                                            'applicationId' => applicationObj.Id
                                        };
        clcommon__Party__c buyerPartyObj = ApplicationOriginationTestHelper.createParty(objectVsIdMap);
        buyerPartyObj.NTB_Label_Report_Generated__c = false;
        buyerPartyObj.NTB_Generated__c = true;
        Database.insert(new  List<clcommon__Party__c>{
                                                        clPartyObj,
                                                        borrowerPartyObj,
                                                        buyerPartyObj
                                                    },true);
        // Creating Dealer Applicant Relationship
        Dealer_Applicant_Relationship__c dealerAppRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(dealerAppRelationObj,true);
        // Creating Content Version
        ContentVersion contentObj = ApplicationOriginationTestHelper.createContentVersion();
        contentObj.Title = ntbName;
        contentObj.PathOnClient = '/'+contentObj.Title+'.pdf';
        Database.insert(contentObj,true);
        // Creating Content Document Link
        List<ContentDocument> contentDocumentsList = [SELECT Id 
                                                        FROM ContentDocument 
                                                        WHERE Title =: ntbName
                                                        LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentsList[0].Id, applicationObj.Id);
        Database.insert(contentDocumentLinkObj,true);
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
    * @description This method is used to get required application details
    * @author Shruti Tamakhuwala | 01-08-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Dealer_Name__c,
                                                                genesis__status__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE Loan_Id__c = '139000' 
                                                        LIMIT 1];
        if(!applicationList.isEmpty()){
            return applicationList[0];
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
                                                    NTB_Label_Report_Generated__c,
                                                    clcommon__Party_Types__c,
                                                    genesis__Application__c,
                                                    clcommon__Account__c  
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__r.Loan_Id__c = '139000' 
                                            AND clcommon__Account__r.Name = 'Jacota Morgan'
                                            LIMIT 1];
        if(!partyList.isEmpty()){
            return partyList;
        }
        return null;
    }

    /**
    * @description This method is used to get log message name
    * @author Shruti Tamakhuwala | 01-08-2025 
    * @return String 
    **/
    private static String getLogMessageName(){
        List<clcommon__Log__c> logList = [SELECT Name
                                            FROM clcommon__Log__c
                                            WHERE Name = 'GenerateNTBSummaryLabels' 
                                            LIMIT 1];
        if(!logList.isEmpty()){
            return (logList[0].Name);
        }           
        return '';
    }

    /**
    * @description This method is used to test success scenario for NTB Summary Template
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testSuccessNTBSummaryLabels(){
        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
            GenerateNTBSummaryLabels.generateNTBSummary();
            System.assertEquals(PortalConstants.EMPTY_STRING, getLogMessageName(), 'No Exception Expcted as it was a success scenario');
            List<clcommon__Party__c> updatedPartyList = TestNTBSummaryLabels.getParty();
            System.assertEquals(true, updatedPartyList[0].NTB_Label_Report_Generated__c , 'NTB_Label_Report_Generated__c  should be true');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check CFA Admin User Access Success
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testCFAAdminUserAccessSuccess(){      
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_CFA_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateSummaryPDF();
            System.assertEquals(PortalConstants.EMPTY_STRING, getLogMessageName(), 'No Exception Expected as CFA Admin User has proper access');
            Test.stopTest();
        }        
    }

    /**
    * @description This method is used to check Credit User Access Success
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testCreditUserAccessSuccess(){       
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_CREDIT);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateSummaryPDF();
            System.assertEquals(PortalConstants.EMPTY_STRING, getLogMessageName(), 'No Exception Expected as Credit User has proper access');
            Test.stopTest();
        }       
    }

    /**
    * @description This method is used to check Admin User Access Success
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testSystemAdminUserAccessSuccess(){        
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateSummaryPDF();
            System.assertEquals(PortalConstants.EMPTY_STRING, getLogMessageName(), 'No Exception Expected as System Admin User has proper access');
            Test.stopTest();
        }        
    }
    
    /**
    * @description This method is used to check the buyer party type if NTB_Label_Report_Generated__c is updated: Success Scenario 
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testCheckBuyerPartySuccess(){        
        String templateName = 'NTB Labels(Buyer'+'\''+'s Name - '+'Jacota Morgan'+').pdf';
        genesis__Applications__c applicationObj = TestNTBSummaryLabels.getApplication();
        List<ContentDocumentLink> contentDocumentLinkList =  [SELECT Id,
                                                                    ContentDocument.Title,
                                                                    ContentDocumentId,
                                                                    linkedEntityId
                                                                FROM ContentDocumentLink
                                                                WHERE linkedEntityId =: applicationObj.Id
                                                                AND ContentDocument.Title =: templateName];
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateSummaryPDF();
            List<clcommon__Party__c> updatedPartyList = TestNTBSummaryLabels.getParty();
            System.assertEquals(true , updatedPartyList[0].NTB_Label_Report_Generated__c, 'Buyers NTB_Label_Report_Generated__c must be true');
            System.assertEquals(1 , contentDocumentLinkList.size(), 'Content Document List should have one record');
            Test.stopTest();
        }       
    }

    /**
    * @description This method is used to check Unauthorized User Access: Error scenario
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testUnauthorizedUserAccessError(){       
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_LOAN_ACCOUNTING);
        System.runAs(userObj) {
            Test.startTest();
            GenerateNTBSummaryLabels.generateSummaryPDF();
            System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'An error message should be displayed for non-admin users.');
            Test.stopTest();
        }        
    }

    /**
    * @description This method is used to test exception scenario for NTB Summary Template: NTB_Generated__c of Buyer party is set to false
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testExceptionNTBSummaryLabels(){       
        List<clcommon__Party__c> partyList = TestNTBSummaryLabels.getParty();
        partyList[0].NTB_Generated__c = false;
        Database.update(partyList,true);
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateSummaryPDF();
            System.assertEquals('GenerateNTBSummaryLabels', getLogMessageName(), 'Exception Expected as NTB_Generated__c of Buyer party is set to false');
            Test.stopTest();
        }        
    }

    /**
    * @description This method is used to check party size exception for a Denied Application
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testPartySizeException(){
        genesis__Applications__c applicationObj = TestNTBSummaryLabels.getApplication();
        applicationObj.genesis__Status__c = PortalConstants.REJECTED_APPLICATION_STATUS;
        Database.update(applicationObj,true);
        List<clcommon__Party__c> partyList =  TestNTBSummaryLabels.getParty();
        partyList[0].NTB_Generated__c = false;
        Database.update(partyList,true);
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateNTBSummary();
            List<clcommon__Party__c> updatedPartyList =  TestNTBSummaryLabels.getParty();
            System.assertEquals(1, updatedPartyList.size(), 'Party List should have one record');
            System.assertEquals('GenerateNTBSummaryLabels', getLogMessageName(), 'Exception Expected as Application is Denied');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the exception in ContentDocument as no proper content document available
    * @author Simran | 08-14-2024 
    **/
    @isTest
    private static void testContentDocumentLinkException(){
        genesis__Applications__c applicationObj = TestNTBSummaryLabels.getApplication();
        List<ContentDocumentLink> contentDocumentLinkList =  [SELECT Id,
                                                                    ContentDocument.Title,
                                                                    ContentDocumentId,
                                                                    linkedEntityId
                                                                FROM ContentDocumentLink
                                                                WHERE linkedEntityId =: applicationObj.Id 
                                                                LIMIT 1];
        List<ContentDocument> contentDocumentsList = [SELECT Id ,Title
                                                        FROM ContentDocument 
                                                        WHERE Id =: contentDocumentLinkList[0].ContentDocumentId
                                                        LIMIT 1]; 
        contentDocumentsList[0].Title = 'ABCRT';        
        Database.update(contentDocumentsList,true);                                                             
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            String result = GenerateNTBSummaryLabels.generateNTBSummary();
            System.assertEquals(1, contentDocumentLinkList.size(), 'Content Document List should have one record');
            System.assertEquals(PortalConstants.EMPTY_STRING, result, 'Result should be empty since Content Document Title mismatched');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check for an exception in application with no buyer party
    * @author Shruti | 01-02-2024  
    **/
    @isTest
    private static void testNullPartyException(){
        List<clcommon__Party__c> partyList = TestNTBSummaryLabels.getParty();
        Database.delete(partyList,true);
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
            Test.startTest();
            GenerateNTBSummaryLabels.generateNTBSummary();
            System.assertEquals('GenerateNTBSummaryLabels', getLogMessageName(), 'Exception Expected as Application has no Buyer Party');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test Standard Controller Access Success
    * @author Shruti Tamakhuwala | 01-03-2025 
    **/
    @isTest
    private static void testStandardControllerSuccess(){
        List<clcommon__Party__c> partyList = TestNTBSummaryLabels.getParty();
        ApexPages.StandardController standardControllerObj = new ApexPages.StandardController(partyList[0]);
        User userObj = TestNTBSummaryLabels.getUser(ConstantValues.PROFILE_ADMIN);
        System.runAs(userObj){
        Test.startTest();
        new GenerateNTBSummaryLabels(standardControllerObj);
        GenerateNTBSummaryLabels.generateNTBSummary();
        System.assertEquals(PortalConstants.EMPTY_STRING, getLogMessageName(), 'No Exception Expected as Standard Controller has proper access');
        Test.stopTest();
        }
    }
}