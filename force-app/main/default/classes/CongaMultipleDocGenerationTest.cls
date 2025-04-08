/**
 * @description       : Test class for CongaMultipleDocGeneration
 * @author            : Simran
 * @group             : 
 * @last modified on  : 09-17-2024
 * @last modified by  : Sk Minsar
**/

@isTest
public class CongaMultipleDocGenerationTest{

    /**
    * @description : This is the test setup method where test data are being created
    * @author Simran | 08-12-2024
    **/
    @testSetup
    static void makeData() {
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(borrowerAccountObj, true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);
        clcommon__Party_Type__c partyTypeObj = ApplicationOriginationTestHelper.createPartyType('SPOUSE');
        Database.insert(partyTypeObj, true);
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
        paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramForBorrowerPartyMap.put('partyTypeId', partyTypeObj.Id);
        paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(borrowerPartyObj);
    }
    
    /**
    * @description : This method is used to check success scenario for all the methods
    * @author Simran | 08-12-2024 
    **/
    @isTest
    public static void checkAllGeneratedTemplates(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        genesis__Applications__c objApplicationDataList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                    CongaMultipleDocGeneration.spousalConsent(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.customizedLoanApproval(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.patronRelease(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.lienSubordinate(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.creditReference(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.modificationAgreementMaturity(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.modificationAgreementMaturityDateExtension(objApplicationDataList.Id);
                    CongaMultipleDocGeneration.loanCommitmentLetter(objApplicationDataList.Id);
                    System.assert(true,'SUCCESS'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description This method is used to check loan commitment letter when app is not active
    * @author Simran | 08-12-2024 
    **/
    @isTest
    public static void checkNonActiveApp(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        genesis__Applications__c objApplicationDataList = [SELECT Id,genesis__Status__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        objApplicationDataList.genesis__Status__c='New Entered';
        Database.update(objApplicationDataList,true);
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.loanCommitmentLetter(objApplicationDataList.Id);
                    System.assertEquals('', response,'Nothing');  
                Test.stopTest();
            }
        }
    } 

    /**
    * @description : Failure scenario of spouse consent template 
    * @author Simran | 08-12-2024 
    **/
    @isTest
    public static void checkSpouseConsentTemplate(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        clcommon__Party_Type__c partyTypeObj  =[SELECT Id,Name FROM clcommon__Party_Type__c WHERE Name='SPOUSE' LIMIT 1];
        partyTypeObj.Name='INSURANCE AGENT';
        Database.update(partyTypeObj,true);
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        clcommon__Party__c partyObj =[SELECT Id, clcommon__Type__c FROM clcommon__Party__c WHERE genesis__Application__c=:applicationObj.Id];
        partyObj.clcommon__Type__c = partyTypeObj.Id;
        Database.update(partyObj,true);
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                String response = CongaMultipleDocGeneration.spousalConsent(applicationObj.Id);
                System.assertEquals('Application does not contain any Spouse', response, 'Spouse Not Available');
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description This method is used to check app id for Spousal Consent template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForSpousalConsentTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.spousalConsent(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Customize template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForCustomizeTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.customizedLoanApproval(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Patron Release template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForPatronReleaseTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.patronRelease(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Lien Subordinate template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForLienSubordinateTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.lienSubordinate(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Credit Reference template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForCreditReferenceTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.creditReference(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for AOI Release template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForAOIReleaseTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    CongaMultipleDocGeneration.aoiCropLetter(objApplicationId);
                    String response = CongaMultipleDocGeneration.aoiCropReleaseLetter(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Assignment of Indemnity template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForIndemnityTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.indemnityCrop(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Modification Agreement Maturity template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForMaturityTemplate(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.modificationAgreementMaturity(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for Modification Agreement Maturity Date template.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForMaturityDateExtension(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.modificationAgreementMaturityDateExtension(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : This method is used to check app id for loan commitment letter.
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkAppIdForLoanCommitmentLetter(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id objApplicationId;
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.loanCommitmentLetter(objApplicationId);
                    System.assertEquals('Application Id is null', response,'Application Id is missing');  
                Test.stopTest();
            }
        }
    }

    
    /**
    * @description This method is used to check custom exception
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkCustomException(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                    String response = CongaMultipleDocGeneration.loanCommitmentLetter('');
                    System.assertEquals('', response, 'Assertion Failed');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : success scenario of all the templates that being generated when there is Insurance Agent 
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkTemplateForInsuranceAgent(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        clcommon__Party_Type__c partyTypeObj  =[SELECT Id,Name FROM clcommon__Party_Type__c WHERE Name='SPOUSE' LIMIT 1];
        partyTypeObj.Name='INSURANCE AGENT';
        Database.update(partyTypeObj,true);
        genesis__Applications__c objApplicationDataList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        clcommon__Party__c objParty =[SELECT Id, clcommon__Type__c FROM clcommon__Party__c WHERE genesis__Application__c=:objApplicationDataList.Id];
        objParty.clcommon__Type__c = partyTypeObj.Id;
        Database.update(objParty,true);
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                CongaMultipleDocGeneration.aoiCropLetter(objApplicationDataList.Id);
                CongaMultipleDocGeneration.aoiCropReleaseLetter(objApplicationDataList.Id);
                CongaMultipleDocGeneration.indemnityCrop(objApplicationDataList.Id);
                System.assert(true,'SUCCESS'); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : failure scenario for AOI Crop Letter 
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkFailureScenarioForAOICropLetter(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        genesis__Applications__c objApplicationDataList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                String response = CongaMultipleDocGeneration.aoiCropLetter(objApplicationDataList.Id);
                System.assertEquals('Application does not contain any Insurance Agent', response, 'Insurance Agent Not Available');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : failure scenario for AOI Crop Release Letter 
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkFailureScenarioForAOICropReleaseLetter(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        genesis__Applications__c objApplicationDataList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                String response = CongaMultipleDocGeneration.aoiCropReleaseLetter(objApplicationDataList.Id);
                System.assertEquals('Application does not contain any Insurance Agent', response, 'Insurance Agent Not Available');
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description : failure scenario for Assignment of Indemnity 
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void checkFailureScenarioForIndemnity(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        genesis__Applications__c objApplicationDataList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                String response = CongaMultipleDocGeneration.indemnityCrop(objApplicationDataList.Id);
                System.assertEquals('Application does not contain any Insurance Agent', response, 'Insurance Agent Not Available');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : scenario to test when we pass wrong app id and it return nothing
    * @author Simran | 08-12-2024
    **/
    @isTest
    public static void failureScenario(){
        User userObj = [SELECT Id FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                CongaMultipleDocGeneration.patronRelease('gbunewmk');
                CongaMultipleDocGeneration.modificationAgreementMaturity('gbunewmk');
                CongaMultipleDocGeneration.modificationAgreementMaturityDateExtension('gbunewmk');
                CongaMultipleDocGeneration.creditReference('gbunewmk');
                String response = CongaMultipleDocGeneration.lienSubordinate('gbunewmk');
                System.assertEquals('', response, '');
                Test.stopTest();
            }
        }
    }
}