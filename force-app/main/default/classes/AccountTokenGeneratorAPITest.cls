/**
 * @description       : Test class for AccountTokenGeneratorAPI
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 09-20-2024
 * @last modified by  : Suraj Kumar
**/
@IsTest
public with sharing class AccountTokenGeneratorAPITest {
    @TestSetup
    static void setup() {
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

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);
    }
    @IsTest 
    private static void testGenerateTokenSysAdmin(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Account dealerAccountObj = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            AccountTokenGeneratorAPI.generateUniqueToken(new List<String>{dealerAccountObj.Id});
            Account updatedDealerAccObj = [SELECT Id, Unique_Id__c FROM Account WHERE Id = :dealerAccountObj.Id];
            System.assertEquals(24, updatedDealerAccObj.Unique_Id__c.length(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    @IsTest 
    private static void testGenerateTokenWithoutId(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Account dealerAccountObj = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            AccountTokenGeneratorAPI.generateUniqueToken(new List<String>());
            Account updatedDealerAccObj = [SELECT Id, Unique_Id__c FROM Account WHERE Id = :dealerAccountObj.Id];
            System.assertEquals(null, updatedDealerAccObj.Unique_Id__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    @IsTest 
    private static void testGenerateTokenCfaAdmin(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'CFA Admin User' AND isActive = true LIMIT 1];
        Account dealerAccountObj = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            AccountTokenGeneratorAPI.generateUniqueToken(new List<String>{dealerAccountObj.Id});
            Account updatedDealerAccObj = [SELECT Id, Unique_Id__c FROM Account WHERE Id = :dealerAccountObj.Id];
            System.assertEquals(24, updatedDealerAccObj.Unique_Id__c.length(), 'Assertion Failed');
            Test.stopTest();
        }
    }
    @IsTest 
    private static void testGenerateTokenPSetAssigned(){
        User userObj = [SELECT Id FROM User 
                                WHERE Id In (SELECT AssigneeId FROM PermissionSetAssignment 
                                                WHERE PermissionSet.name = 'create_dealer_account') 
                                                AND IsActive = true LIMIT 1];
        Account dealerAccountObj = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            AccountTokenGeneratorAPI.generateUniqueToken(new List<String>{dealerAccountObj.Id});
            Account updatedDealerAccObj = [SELECT Id, Unique_Id__c FROM Account WHERE Id = :dealerAccountObj.Id];
            System.assertEquals(24, updatedDealerAccObj.Unique_Id__c.length(), 'Assertion Failed');
            Test.stopTest();
        }                                         
    }
}