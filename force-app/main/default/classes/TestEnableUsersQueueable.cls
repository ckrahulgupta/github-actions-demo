/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 19-04-2023
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-04-2023   Subham Nandi   Initial Version
**/
@isTest
global class TestEnableUsersQueueable {
    @TestSetup
    static void makeData(){
        //Create Account
        Account objUserAccount = TestClassHelper.createAccount(TestClassHelper.createBusinessInfo());
        Contact objUserContact = TestClassHelper.createContact();
        objUserContact.AccountId = objUserAccount.Id;
        Database.update(objUserContact,true);
    }
    @isTest
    static void testCase1() {
        Test.startTest();
        Contact objContact =  [ SELECT Id 
                                FROM Contact 
                                LIMIT 1];
        Profile objProfile = [SELECT Id 
                                FROM Profile
                                WHERE Name = 'Grower'];
        ID jobID = System.enqueueJob(new EnableUsersQueueable( objContact.Id, objProfile.Id));
        Test.stopTest();
    }
    

    @isTest
    static void testCase2(){
        Test.startTest();
        Contact objContact =  [ SELECT Id 
                                FROM Contact 
                                LIMIT 1];
        Profile getProfile = [SELECT Id FROM Profile WHERE Name = 'Grower'];
        User objUser = new User(Alias = 'newUser', Email='cfanewuser@yopmail.com',EmailEncodingKey='UTF-8',
                                        LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                        ProfileId = getProfile.Id, ContactId = objContact.Id,
                                        TimeZoneSidKey='America/Los_Angeles', UserName='cfanewuser@yopmail.com');
        Database.insert(objUser, false);
        ID jobID = System.enqueueJob(new EnableUsersQueueable( objContact.Id, getProfile.Id));
        Test.stopTest();
    }
}