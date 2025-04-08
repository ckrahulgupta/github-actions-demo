/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-17-2024
 * @last modified by  : Krishanu Chinya
**/
@isTest
private class ResetEmailChangeJobTest {
    @TestSetup
    static void setup(){
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '867017636';
        Database.insert(borrowerContactObj,true);

        ContactHistory testContactHistory = new ContactHistory(
            ContactId = borrowerContactObj.Id,
            Field = 'New_Email__c'
        );
        insert testContactHistory;
    }
    
    /**
    * @description 
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @isTest
    static void testResetEmailChangeJob() {
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            Contact testContact = [SELECT Id, New_Email__c FROM Contact WHERE genesis__SSN__c = '867017636'];
            testContact.New_Email__c = 'newborrower.email@yopmail.com';
            Database.update(testContact, true);
            // Schedule the job
            ResetEmailChangeJob job = new ResetEmailChangeJob();
            job.execute(null);
            Test.stopTest();
            
            // Verify that the contact's New_Email__c field is reset to null
            testContact = [SELECT Id, New_Email__c FROM Contact WHERE genesis__SSN__c = '867017636'];
            System.assertEquals(null, testContact.New_Email__c);
        }
    }
}