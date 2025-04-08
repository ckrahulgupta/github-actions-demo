/**
 * @description       : test class for PortalApplicationCreationGrowerHandler
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : Krishanu Chinya
**/
@isTest
public with sharing class PortalAppCreationGrowerHandlerTest {
    @testSetup
    static void setup(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
    }

    /**
    * @description : fetches a grower user
    * @author Krishanu Chinya | 09-12-2024 
    * @return User 
    **/
    private static User fetchGrowerUser(){
        List<User> growerUserList = [SELECT Id,
                                Account.ParentId,
                                ContactId
                            FROM User
                            WHERE ContactId IN (
                                SELECT Id
                                    FROM Contact
                                    WHERE Name = 'Jasmine Albin')];
        if(growerUserList.isEmpty()){
            return null;
        }
        return growerUserList[0];
    }

    /**
    * @description : testing setRelation method to create party of dealer relations
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    public static void testSetRelation() {
        User growerUser = fetchGrowerUser();

        List<Account> dealerAccList = [SELECT Id,
                                                name 
                                        FROM Account 
                                        WHERE RecordType.name = :PortalConstants.DEALER_PROFILE];

        List<clcommon__Relationship__c> dealerRelationList = [SELECT Id, 
                                                                        clcommon__Entity__c,
                                                                        clcommon__Related_Entity__c, 
                                                                        clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Entity__c = :dealerAccList[0].id
                                                                AND clcommon__Relationship__r.Name IN (
                                                                        :PortalConstants.CERTIFIED_LENDER, 
                                                                        :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                        :PortalConstants.INQUIRY,
                                                                        :PortalConstants.INQUIRY_PLUS,
                                                                        :PortalConstants.FIELD_STAFF_AGENT
                                                                    )];

            List<String> relationIdList = new List<String>();

            for (clcommon__Relationship__c relation : dealerRelationList) {
                relationIdList.add(relation.clcommon__Related_Entity__c);
            }

            List<genesis__Applications__c> appList = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE Dealer_name__c = :dealerAccList[0].id];

            List<Contact> relationContactList = [SELECT Account.Id, 
                                                            Id,
                                                            Account.RecordType.Name 
                                                    FROM Contact 
                                                    WHERE AccountId IN :relationIdList];

        
        Test.startTest();
        System.runAs(growerUser) {
            List<clcommon__Party__c> partyList = PortalApplicationCreationGrowerHandler.setRelation(relationContactList,appList[0]);
            System.assertEquals(partyList[0].genesis__Application__c, appList[0].Id,PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing validateLoggedInGrowerSSN to Validate Logged In Grower SSN
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    public static void testValidateLoggedInGrowerSSN() {
        User growerUser = fetchGrowerUser();

        List<Contact> borrowerContactList = [SELECT Id,
                                                    genesis__ssn__c
                                                FROM Contact
                                                WHERE Name = 'Jasmine Albin'];
        
        Test.startTest();
        System.runAs(growerUser) {
            PortalApplicationCreationGrowerHandler.validateLoggedInGrowerSSN(borrowerContactList[0]);
            System.assert(true,PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing validateLoggedInGrowerSSN to Validate Logged In Grower SSN
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    public static void testValidateLoggedInGrowerSSNError() {
        User growerUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<Contact> borrowerContactList = [SELECT Id,
                                                    genesis__ssn__c
                                                FROM Contact
                                                WHERE Name = 'Jasmine Albin'];
        
        Test.startTest();
        System.runAs(growerUser) {
            try{
                PortalApplicationCreationGrowerHandler.validateLoggedInGrowerSSN(borrowerContactList[0]);
            }catch (CustomException e) {
                System.assertEquals(PortalConstants.DUPLICATE_SSN_OR_EMAIL, e.getMessage(), 'Assertion Failed');
            }
        }
        Test.stopTest();
    }

    /**
    * @description : testing checkSolePropDetails to Check Sole Prop Details
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    public static void testCheckSolePropDetails() {
        User growerUser = fetchGrowerUser();

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                            genesis__Tax_Identification_Number__c 
                                                                    FROM genesis__Business_Information__c 
                                                                    WHERE genesis__Tax_Identification_Number__c='339814629'];
        businessInfoList[0].genesis__Tax_Identification_Number__c = '927483938';
        Database.update(businessInfoList);
        List<Account> accList = [SELECT Id, 
                                        Name,
                                        genesis__Business_Information__r.genesis__Tax_Identification_Number__c 
                                FROM Account 
                                WHERE Name = 'Green Crops Pvt. Ltd.'];
        Test.startTest();
        System.runAs(growerUser) {
            Account resultAcc = PortalApplicationCreationGrowerHandler.checkSolePropDetails(businessInfoList[0], PortalConstants.CORPORATION, accList[0]);
            System.assertEquals('927483938', resultAcc.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing setSSN method
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testSetSSN() {
        User growerUser = fetchGrowerUser();

        List<Contact> growerContactList = [SELECT Id FROM Contact WHERE Id=: growerUser.ContactId];
        growerContactList[0].genesis__SSN__c = null;
        growerContactList[0].Confirm_SSN__c = null;
        Database.update(growerContactList, true);
        
        Map<String, Object> requestDataMap = new Map<String, Object>{
            'ssn' => '123-45-6789',
            'confirmSSN' => '123-45-6789'
        };
        
        Test.startTest();
        System.runAs(growerUser) {
            List<Contact> updatedContacts = PortalApplicationCreationGrowerHandler.setSSN(PortalConstants.SOLE_PROP_ENTITY, growerContactList, requestDataMap);
            System.assertEquals('123-45-6789', updatedContacts[0].genesis__SSN__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals('123-45-6789', updatedContacts[0].Confirm_SSN__c, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing updateCertifiedLender to update CL in an application
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testUpdateCertifiedLender() {
        User growerUser = fetchGrowerUser();

        List<Account> dealerAccList = [SELECT Id,
                                                name 
                                        FROM Account 
                                        WHERE RecordType.name = :PortalConstants.DEALER_PROFILE];

        List<clcommon__Relationship__c> dealerRelationList = [SELECT Id, 
                                                                    clcommon__Entity__c,
                                                                    clcommon__Related_Entity__c, 
                                                                    clcommon__Relationship__r.Name
                                                            FROM clcommon__Relationship__c
                                                            WHERE clcommon__Entity__c = :dealerAccList[0].id
                                                            AND clcommon__Relationship__r.Name IN (
                                                                    :PortalConstants.CERTIFIED_LENDER, 
                                                                    :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                    :PortalConstants.INQUIRY,
                                                                    :PortalConstants.INQUIRY_PLUS,
                                                                    :PortalConstants.FIELD_STAFF_AGENT
                                                                )];

        List<clcommon__Relationship__c> saDealerRelationList = [SELECT Id, 
                                                                        clcommon__Entity__c,
                                                                        clcommon__Related_Entity__c, 
                                                                        clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Entity__c = :dealerAccList[0].id
                                                                AND clcommon__Relationship__r.Name IN (
                                                                        :PortalConstants.SALES_AGENT_PLUS 
                                                                    )];

        List<genesis__Applications__c> appList = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE Dealer_name__c = :dealerAccList[0].id];
        appList[0].Certified_Lender__c = null;
        Database.update(appList, true);
        
        Test.startTest();
        System.runAs(growerUser) {
            genesis__Applications__c resultApp = PortalApplicationCreationGrowerHandler.updateCertifiedLender(dealerRelationList,saDealerRelationList,appList[0]);
            
            System.assert(resultApp.Certified_Lender__c != null, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing updateParty to create SA party in application
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testUpdatePartyForSA() {
        User growerUser = fetchGrowerUser();

        List<Account> dealerAccList = [SELECT Id,
                                                name 
                                        FROM Account 
                                        WHERE RecordType.name = :PortalConstants.DEALER_PROFILE];

        List<clcommon__Relationship__c> saDealerRelationList = [SELECT Id, 
                                                                        clcommon__Entity__c,
                                                                        clcommon__Related_Entity__c, 
                                                                        clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Entity__c = :dealerAccList[0].id
                                                                AND clcommon__Relationship__r.Name IN ( 
                                                                        :PortalConstants.SALES_AGENT_PLUS )];

        List<genesis__Applications__c> appList = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE Dealer_name__c = :dealerAccList[0].id];
        appList[0].Sales_Agent__c = null;
        Database.update(appList, true);

        clcommon__Party__c partyToCreate = new clcommon__Party__c();

        
        Test.startTest();
        System.runAs(growerUser) {
            PortalApplicationCreationGrowerHandler.updateParty(saDealerRelationList,appList[0],partyToCreate);
            System.assert(appList[0].Sales_Agent__c != null, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing updateParty to create CL party in application
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testUpdatePartyForCL() {
        User growerUser = fetchGrowerUser();

        List<Account> dealerAccList = [SELECT Id,
                                                name 
                                        FROM Account 
                                        WHERE RecordType.name = :PortalConstants.DEALER_PROFILE];

        List<clcommon__Relationship__c> saDealerRelationList = [SELECT Id, 
                                                                        clcommon__Entity__c,
                                                                        clcommon__Related_Entity__c, 
                                                                        clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Entity__c = :dealerAccList[0].id
                                                                AND clcommon__Relationship__r.Name IN (
                                                                        :PortalConstants.CERTIFIED_LENDER, 
                                                                        :PortalConstants.CERTIFIED_LENDER_PLUS )];

        List<genesis__Applications__c> appList = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE Dealer_name__c = :dealerAccList[0].id];
        appList[0].Certified_Lender__c = null;
        Database.update(appList, true);

        clcommon__Party__c partyToCreate = new clcommon__Party__c();

        
        Test.startTest();
        System.runAs(growerUser) {
            PortalApplicationCreationGrowerHandler.updateParty(saDealerRelationList,appList[0],partyToCreate);
            System.assert(appList[0].Certified_Lender__c != null, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description : testing checkDetails mehthod
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testCheckDetails() {
        User growerUser = fetchGrowerUser();

        List<Account> corpAccList = [SELECT Id,
                                            name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__business_information__c
                                    FROM Account 
                                    WHERE clcommon__legal_entity_type__r.name = 'Corporation'
                                    AND RecordType.name = 'Grower'];

        List<genesis__Business_Information__c> corpBusinessInfoList = [SELECT Id,
                                                                                Name,
                                                                                genesis__Tax_Identification_Number__c 
                                                                        FROM genesis__Business_Information__c 
                                                                        WHERE Id =: corpAccList[0].genesis__business_information__c];
        Contact objCorporateContact = new Contact();

        
        Test.startTest();
        System.runAs(growerUser) {
            PortalApplicationCreationGrowerHandler.DBAWrapper objWrapper = new PortalApplicationCreationGrowerHandler.DBAWrapper();
            objWrapper = PortalApplicationCreationGrowerHandler.checkDetails(corpAccList[0], corpBusinessInfoList[0], objCorporateContact);
            System.assert(true, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description  : testing checkDetails mehthod for exception scenario
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testCheckDetailsNotDuplicate() {
        User growerUser = fetchGrowerUser();

        List<Account> corpAccList = [SELECT Id,
                                            name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__business_information__c
                                    FROM Account 
                                    WHERE clcommon__legal_entity_type__r.name = 'Corporation'
                                    AND RecordType.name = 'Grower'];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name =: PortalConstants.LIMITED_LIABILITY_COMPANY];
        corpAccList[0].clcommon__Legal_Entity_Type__c = legalEntityList[0].Id;
        Database.update(corpAccList, true);

        genesis__Business_Information__c businessInfo = new genesis__Business_Information__c();
        businessInfo.genesis__Tax_Identification_Number__c = '890233363';
        Database.insert(businessInfo, true);

        Contact corporationContact = new Contact();

        Test.startTest();
        System.runAs(growerUser) {
            PortalApplicationCreationGrowerHandler.DBAWrapper objWrapper = new PortalApplicationCreationGrowerHandler.DBAWrapper();
            try{
                objWrapper = PortalApplicationCreationGrowerHandler.checkDetails(corpAccList[0], businessInfo, corporationContact);
            }catch (CustomException e) {
                System.assertEquals(PortalConstants.DUPLICATE_TIN, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }

    /**
    * @description  : testing checkDetails mehthod
    * @author Krishanu Chinya | 09-13-2024 
    **/
    @isTest
    static void testCheckDetailsDuplicateTin() {
        User growerUser = fetchGrowerUser();

        List<Account> corpAccList = [SELECT Id,
                                            name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__business_information__c
                                    FROM Account 
                                    WHERE clcommon__legal_entity_type__r.name = 'Corporation'
                                    AND RecordType.name = 'Grower'];

        List<genesis__Business_Information__c> corpBusinessInfoList = [SELECT Id,
                                                                                Name,
                                                                                genesis__Tax_Identification_Number__c 
                                                                        FROM genesis__Business_Information__c 
                                                                        WHERE Id !=: corpAccList[0].genesis__business_information__c];
        corpBusinessInfoList[0].genesis__Tax_Identification_Number__c = '943350702';
        Database.update(corpBusinessInfoList, true);
        Contact objCorporateContact = new Contact();

        
        Test.startTest();
        System.runAs(growerUser) {
            PortalApplicationCreationGrowerHandler.DBAWrapper objWrapper = new PortalApplicationCreationGrowerHandler.DBAWrapper();
            try{
                objWrapper = PortalApplicationCreationGrowerHandler.checkDetails(corpAccList[0], corpBusinessInfoList[0], objCorporateContact);
            }catch (CustomException e) {
                System.assertEquals(PortalConstants.DUPLICATE_TIN, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
}