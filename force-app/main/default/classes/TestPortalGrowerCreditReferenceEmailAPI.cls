/**
 * @description       : this is the test class for PortalGrowerCreditReferenceEmailAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-21-2025
 * @last modified by  : Ayan Khanra
**/

@isTest
private with sharing class TestPortalGrowerCreditReferenceEmailAPI {
    /**
    * @description : This method is used to prepare test data
    * @author Ayan Khanra | 01-21-2025 
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
        //creating a new business info record
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        //creating dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id, newPartnerProgramObj.id);
        //creating a new cl product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);
        //creating a new cl purpose
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        //creating individual sole prop legal entity
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        //creating a corporation legal entity
        clcommon__Legal_Entity__c corporationLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{legalEntityObj,corporationLegalEntityObj},true);
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        //creating the borrower account
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account>{dealerAccountObj,borrowerAccountObj},true);
        //creating a borrower contact
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        //creating a new sales agent account
        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);
        //creating a sales agent contact
        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        //creating a cl account
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);
        //creating the cl contact
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(new List<Contact>{borrowerContactObj,contactObj,clContactObj},true);
        User borrowerUser = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.id);
        //creating a new sales agent user
        User userObj = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.id);
        Database.insert(new List<User>{borrowerUser,userObj},true);
        //creating an application data map
        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        };
        //creating a new application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Certified_Lender__c = clAccountObj.id;
        applicationObj.Dealer_Name__c = dealerAccountObj.id;
        //creating a new Dealer Applicant Relationship for the Application
        Dealer_Applicant_Relationship__c dealerGrowerRelation = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerGrowerRelation,true);
        //updating the dealer applicant look up on the application
        applicationObj.Dealer_Applicant_Relationship__c=dealerGrowerRelation.id;
        Database.insert(applicationObj,true);
        //creating various party type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c boPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj,prPartyTypeObj,boPartyTypeObj,saPartyTypeObj},true);
        //creating the sales agent party and the borrower party of the application
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => saPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c saPartyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        saPartyObj.clcommon__User__c = userObj.id;
        Map<String,Id> borrowerPartyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => boPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(borrowerPartyParamMap);
        Dealer_Applicant_Relationship__c dealerApplicantRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerApplicantRelObj,true);
        borrowerPartyObj=ApplicationOriginationTestHelper.insertIndividualPartyDetails(borrowerPartyObj,dealerApplicantRelObj.id);
        Database.insert(new List<clcommon__Party__c>{saPartyObj,borrowerpartyObj},true);
    }

    /**
    * @description used to return the user
    * @author Rakesh Saraf | 01-11-2025 
    * @param applicationList 
    * @return List<user> 
    **/
    private static List<user> getUserList(List<genesis__Applications__c> applicationList){
        return [SELECT Id
                FROM USER 
                WHERE ContactId = : applicationList[0].genesis__Contact__c 
                        AND Profile.Name = 'Grower' 
                LIMIT 1];
    }

    /**
    * @description used to return the list of applications
    * @author Rakesh Saraf | 01-11-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplicationsList(){
        return [SELECT Id,
                        genesis__Contact__c,
                        Certified_Lender__c,
                        Sales_Agent__c,
                        genesis__Account__c 
                FROM genesis__Applications__c 
                LIMIT 1];
    }

    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalGrowerCreditReferenceEmailAPI' Limit 1];
    }

    /**
    * @description Test case for success when a buyer submits an application
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testSuccessForIndividual() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList=getApplicationsList();
        List<User> userList = getUserList(applicationList);
        requestMap.put('applicationId', applicationList[0].Id);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Email not send');
            Test.stopTest();
        }
    }
    
    /**
    * @description This test method test gives exception for missing application id in paremeter and logs exception
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testParameterMissingExceptionAndCreateLog() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList=getApplicationsList();
        List<User> userList = getUserList(applicationList);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email send');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }
    }

    /**
    * @description Test case where the applicant contact is missing from the Dealer Applicant Relationship Object for the Application
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testApplicationDetailsMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        applicationList[0].Certified_Lender__c=null;
        applicationList[0].Sales_Agent__c=null;
        Database.update(applicationList,true);
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[SELECT Id,
                                                                                Applicant__c,
                                                                                Applicant_Contact__c
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        LIMIT 1];
        dealerApplicantRelList[0].Applicant_Contact__c=null;        
        dealerApplicantRelList[0].Applicant__c=null;        
        Database.update(dealerApplicantRelList,true);
        List<User> userList = getUserList(applicationList);
        requestMap.put('applicationId', applicationList[0].Id);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email sent');
            Test.stopTest();
        }
    }

    /**
    * @description Test case where the email in the contact of the cl is set to null
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testCertifiedLenderEmailIdMissing() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        List<User> userList = getUserList(applicationList);
        List<Contact> clContactList = [SELECT Id,
                                                Email,
                                                AccountId
                                        FROM Contact
                                        WHERE AccountId=:applicationList[0].Certified_Lender__c];
        clContactList[0].Email=null;
        Database.update(clContactList,true);
        requestMap.put('applicationId', applicationList[0].Id);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email send although Email of cl is missing');
            Test.stopTest();
        }
    }

    /**
    * @description Test case when the email of the sales agent is msising
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testSalesAgentEmailMissing() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        applicationList[0].Certified_Lender__c=null;
        Database.update(applicationList,true);
        List<User> userList = getUserList(applicationList);
        List<Contact> saContactList = [SELECT Id,
                                            Email,
                                            AccountId
                                        FROM Contact
                                        WHERE AccountId=:applicationList[0].Sales_Agent__c];
        saContactList[0].Email=null;
        Database.update(saContactList,true);
        requestMap.put('applicationId', applicationList[0].Id);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email send although email of sales agent missing');
            Test.stopTest();
        }
    }

    /**
    * @description Test case when the sales agent is not present in the application but ut has irc
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testSalesAgentMissing() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        applicationList[0].Sales_Agent__c=null;
        applicationList[0].Internal_Reference_Code__c='12223424';
        Database.update(applicationList,true);
        List<User> userList = getUserList(applicationList);
        requestMap.put('applicationId', applicationList[0].Id);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Email not send');
            Test.stopTest();
        }
    }
    
    /**
    * @description : This test method gives excption for not having a legal entity type
    * @author Ayan Khanra | 01-20-2025 
    **/
    @isTest
    private static void testLegalEntityMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        Account borrowerAccountObj = new Account(Id=applicationList[0].genesis__Account__c);
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = null;
        Database.update(borrowerAccountObj,true);                                    
        List<genesis__Applications__c> updatedApplicationList = getApplicationsList();
        requestMap.put('applicationId', updatedApplicationList[0].Id);
        List<User> userList = getUserList(updatedApplicationList);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email send although leagal entity missing');
            Test.stopTest();
        }
    }

    /**
    * @description : This method gives exception for not being valid user
    * @author Ayan Khanra | 01-20-2025 
    **/
    @isTest
    private static void testInvalidLoggedInUserException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        List<clcommon__party__c> borrowerPartyObj = [SELECT ID 
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c=:applicationList[0].Id 
                                                    AND clcommon__Type__r.Name='BORROWER' 
                                                    LIMIT 1];                                 
        Database.delete(borrowerPartyObj,true);
        requestMap.put('applicationId', applicationList[0].Id);
        List<User> userList = getUserList(applicationList);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email send although borrower party not present');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives excption for not having a legal entity type
    * @author Ayan Khanra | 01-20-2025 
    **/
    @isTest
    private static void testClAndSaContactMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplicationsList();
        List<User> userList = getUserList(applicationList);
        Account accountObj = new Account(
            Name = 'Example Account',
            Industry = 'Technology',
            Phone = '123-456-7890',
            Website = 'https://example.com',
            AnnualRevenue = 1000000
        );
        Database.insert(accountObj,true);
        List<Contact> contactList = [SELECT ID 
                                    FROM Contact 
                                    WHERE Email 
                                    IN ('ross.geller@yopmail.com','tony.Stark@yopmail.com')];
        for(Contact contactObj : contactList){
            contactObj.AccountId = accountObj.Id;
        }
        Database.update(contactList,true);                           
        requestMap.put('applicationId', applicationList[0].Id);
        System.runAs(userList[0]) {
            Test.startTest();
            //Calling the API
            PortalGrowerCreditReferenceEmailAPI creditRefEmailAPIInst = new PortalGrowerCreditReferenceEmailAPI();
            clcommon.Response response = creditRefEmailAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Email not send');
            Test.stopTest();
        }
    }
}