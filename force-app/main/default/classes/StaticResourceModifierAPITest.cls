/**
 * @description       : This the test class of StaticResourceModifierAPI
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public with sharing class StaticResourceModifierAPITest {
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

        ContentVersion dealerNavBanner = ApplicationOriginationTestHelper.createContentVersion(
            new Map<String, String>{'Title' => 'Dealer Portal Nav Banner',
                                        'File Extension' => 'png'}, 'Test Dealer Portal Nav Banner'
        );

        ContentVersion growerLogo = ApplicationOriginationTestHelper.createContentVersion(
            new Map<String, String>{'Title' => 'Grower Portal Logo',
                                        'File Extension' => 'png'}, 'Test Grower Portal Logo'
        );

        ContentVersion growerNavBanner = ApplicationOriginationTestHelper.createContentVersion(
            new Map<String, String>{'Title' => 'Grower Portal Nav Banner',
                                        'File Extension' => 'png'}, 'Test Grower Portal Nav Banner'
        );

        Database.insert(new List<ContentVersion>{dealerLogo, dealerNavBanner, growerLogo, growerNavBanner}, true);
    }

    @IsTest
    private static void testStaticResourceModifierAPI(){
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                    Name
                                                                FROM CFA_Partner_Program__c
                                                                WHERE Base_Rate__r.Name = 'CFA Advantage Rate'
                                                                LIMIT 1];
        // Query for the ContentDocument using the ContentVersion's ContentDocumentId
        List<ContentDocument> contentDocumentList = [SELECT Id
                                                        FROM ContentDocument
                                                        WHERE Title IN ('Dealer Portal Logo', 
                                                                        'Dealer Portal Nav Banner', 
                                                                        'Grower Portal Logo', 
                                                                        'Grower Portal Nav Banner')
                                                        ORDER BY Title ASC];
        List<String> contentDocIdList = new List<String>();
        for(ContentDocument eachContentDocument : contentDocumentList){
            contentDocIdList.add('[' + eachContentDocument.Id + ']');
        }
        StaticResourceModifierAPI.FlowInputsWrapper flowInputObj = new StaticResourceModifierAPI.FlowInputsWrapper();
        flowInputObj.contentDocIdList = contentDocIdList;
        flowInputObj.coopTypeName = partnerProgramList[0].Name;
        flowInputObj.programId = partnerProgramList[0].Id;

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            StaticResourceModifierAPI.uploadImage(new List<StaticResourceModifierAPI.FlowInputsWrapper>{flowInputObj});
            Test.stopTest();
            System.assertEquals(0, [SELECT Id FROM clcommon__Log__c].size(), 'Static Resource Creation Failed');
        }
    }
    @IsTest
    private static void testNullContentDocId(){
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                    Name
                                                                FROM CFA_Partner_Program__c
                                                                WHERE Base_Rate__r.Name = 'CFA Advantage Rate'
                                                                LIMIT 1];
        List<String> contentDocIdList = new List<String>();
        for(Integer eachContentDocument = 0; eachContentDocument < 4; eachContentDocument++){
            contentDocIdList.add('[]');
        }
        StaticResourceModifierAPI.FlowInputsWrapper flowInputObj = new StaticResourceModifierAPI.FlowInputsWrapper();
        flowInputObj.contentDocIdList = contentDocIdList;
        flowInputObj.coopTypeName = partnerProgramList[0].Name;
        flowInputObj.programId = partnerProgramList[0].Id;

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            StaticResourceModifierAPI.uploadImage(new List<StaticResourceModifierAPI.FlowInputsWrapper>{flowInputObj});
            Test.stopTest();
            System.assertEquals(0, [SELECT Id FROM clcommon__Log__c].size(), 'Static Resource Creation Failed');
        }
    }
    @IsTest
    private static void testCheckAccessException(){
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                    Name
                                                                FROM CFA_Partner_Program__c
                                                                WHERE Base_Rate__r.Name = 'CFA Advantage Rate'
                                                                LIMIT 1];
        // Query for the ContentDocument using the ContentVersion's ContentDocumentId
        List<ContentDocument> contentDocumentList = [SELECT Id
                                                        FROM ContentDocument
                                                        WHERE Title IN ('Dealer Portal Logo', 
                                                                        'Dealer Portal Nav Banner', 
                                                                        'Grower Portal Logo', 
                                                                        'Grower Portal Nav Banner')
                                                        ORDER BY Title ASC];
        List<String> contentDocIdList = new List<String>();
        for(ContentDocument eachContentDocument : contentDocumentList){
            contentDocIdList.add('[' + eachContentDocument.Id + ']');
        }
        StaticResourceModifierAPI.FlowInputsWrapper flowInputObj = new StaticResourceModifierAPI.FlowInputsWrapper();
        flowInputObj.contentDocIdList = contentDocIdList;
        flowInputObj.coopTypeName = partnerProgramList[0].Name;
        flowInputObj.programId = partnerProgramList[0].Id;

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'AgVend External User Profile' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            StaticResourceModifierAPI.uploadImage(new List<StaticResourceModifierAPI.FlowInputsWrapper>{flowInputObj});
            Test.stopTest();
            System.assertEquals(1, [SELECT Id FROM clcommon__Log__c].size(), 'Static Resource Creation Failed');
        }
    }
    @IsTest
    private static void testException(){
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                    Name
                                                                FROM CFA_Partner_Program__c
                                                                WHERE Base_Rate__r.Name = 'CFA Advantage Rate'
                                                                LIMIT 1];
        // Query for the ContentDocument using the ContentVersion's ContentDocumentId
        List<ContentDocument> contentDocumentList = [SELECT Id
                                                        FROM ContentDocument
                                                        WHERE Title IN ('Dealer Portal Logo', 
                                                                        'Dealer Portal Nav Banner', 
                                                                        'Grower Portal Logo', 
                                                                        'Grower Portal Nav Banner')
                                                        ORDER BY Title ASC];
        List<String> contentDocIdList = new List<String>();
        for(ContentDocument eachContentDocument : contentDocumentList){
            contentDocIdList.add(eachContentDocument.Id);
        }
        StaticResourceModifierAPI.FlowInputsWrapper flowInputObj = new StaticResourceModifierAPI.FlowInputsWrapper();
        flowInputObj.contentDocIdList = contentDocIdList;
        flowInputObj.coopTypeName = partnerProgramList[0].Name;
        flowInputObj.programId = partnerProgramList[0].Id;

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            StaticResourceModifierAPI.uploadImage(new List<StaticResourceModifierAPI.FlowInputsWrapper>{flowInputObj});
            Test.stopTest();
            System.assertEquals(1, [SELECT Id FROM clcommon__Log__c].size(), 'Static Resource Creation Failed');
        }
    }
}