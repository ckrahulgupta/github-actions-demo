/**
 * @description       : This is the test class of CFAPartnerProgramUpdateQueueable.
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public with sharing class CFAPartnerProgramUpdateQueueableTest {
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

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

         // Creating ContentVersion
         ContentVersion dealerLogo = ApplicationOriginationTestHelper.createContentVersion(
            new Map<String, String>{'Title' => 'Dealer Portal Logo'}, 'Test Dealer Portal Logo'
        );

        Database.insert(new List<ContentVersion>{dealerLogo}, true);
    }
    @IsTest
    private static void testCFAPartnerProgramUpdateQueueable(){
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                    Name
                                                                FROM CFA_Partner_Program__c
                                                                WHERE Base_Rate__r.Name = 'CFA Advantage Rate'
                                                                LIMIT 1];
        List<ContentVersion> contentVersionList = [SELECT Id,
                                                            ContentDocumentId
                                                        FROM ContentVersion
                                                        WHERE Title = 'Dealer Portal Logo'];
        String dealerLogo = (partnerProgramList[0].Name + '_Dealer_Portal_Logo');
        String dealerNavBanner = (partnerProgramList[0].Name + '_Dealer_Portal_Nav_Banner');
        String growerLogo = (partnerProgramList[0].Name + '_Grower_Portal_Logo');
        String growerNavBanner = (partnerProgramList[0].Name + '_Grower_Portal_Nav_Banner');
        Map<String, String> fieldToSrMap = new Map<String, String>{'_Dealer_Portal_Logo' => dealerLogo,
                                                                    '_Dealer_Portal_Nav_Banner' => dealerNavBanner,
                                                                    '_Grower_Portal_Logo' => growerLogo,
                                                                    '_Grower_Portal_Nav_Banner' => growerNavBanner};

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            System.enqueueJob(new CFAPartnerProgramUpdateQueueable(fieldToSrMap, partnerProgramList[0].Id, contentVersionList[0].ContentDocumentId));
            Test.stopTest();
            partnerProgramList = [SELECT Id,
                                        Dealer_Portal_Nav_Banner__c,
                                        Grower_Portal_Nav_Banner__c,
                                        Dealer_Portal_Logo__c,
                                        Grower_Portal_Logo__c
                                    FROM CFA_Partner_Program__c
                                    WHERE Id =: partnerProgramList[0].Id
                                    LIMIT 1];
            System.assertEquals(partnerProgramList[0].Dealer_Portal_Nav_Banner__c, dealerNavBanner, 'Field Update Failed');
            System.assertEquals(partnerProgramList[0].Grower_Portal_Nav_Banner__c, growerNavBanner, 'Field Update Failed');
            System.assertEquals(partnerProgramList[0].Dealer_Portal_Logo__c, dealerLogo, 'Field Update Failed');
            System.assertEquals(partnerProgramList[0].Grower_Portal_Logo__c, growerLogo, 'Field Update Failed');
        }
    }
    @IsTest
    private static void testNoProgramException(){
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            try{
                System.enqueueJob(new CFAPartnerProgramUpdateQueueable(new Map<String, String>(), '', ''));
            } catch(Exception exceptionObj) {
                System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }
}