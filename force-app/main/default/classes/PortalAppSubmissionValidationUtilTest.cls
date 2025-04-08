/**
 * @description       : test class for PortalAppSubmissionValidationUtil
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
private without sharing class PortalAppSubmissionValidationUtilTest {
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

        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();

        Database.insert(new List<genesis__Business_Information__c>{
        dealerBusinessInfoObj,
        borrowerBusinessInfoObj
        }, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);

        // // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        // // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.CIF_Number__c = '141623';
        borrowerAccountObj.BillingStreet = 'Action area 1';

        Database.insert(new List<Account>{
            clAccountObj,
            borrowerAccountObj
        }, true);


        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        // // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);

        Database.insert(new List<Contact>{
            clContactObj,
            borrowerContactObj
        },true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{
            clUserObj,
            borrowerUserObj
        },true);
        
        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  clAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Agreement_Sign__c = true;
        Database.insert(applicationObj, true);

        
        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        
        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{
            clPartyTypeObj,
            borrowerPartyTypeObj
        }, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c>();
        clcommon__party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        clPartyObj.ownerId = clUserObj.Id;
        partyObjList.add(clPartyObj);

        Dealer_Applicant_Relationship__c dealerApplicantRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);

        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerApplicantRelObj},true);

        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__party__c borrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj);
        // borrowerParty.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;
        borrowerParty.Marital_Status__c = PortalConstants.MARITAL_STATUS_MARRIED;
        borrowerParty = ApplicationOriginationTestHelper.insertIndividualPartyDetails(borrowerParty, dealerApplicantRelObj.id);
        partyObjList.add(borrowerParty);

        ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);

        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        existingApplicationObj.genesis__Loan_Number__c = '116623344';
        existingApplicationObj.Signing_Method__c = 'Paper - Scanned';
        existingApplicationObj.Submitted_to_CFA__c=Date.newInstance(2024, 08, 08);
        Database.insert(existingApplicationObj,true);

        Map<String,Id> paramForExistingBorrower = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingAppPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForExistingBorrower,borrowerAccountObj);
        existingAppPartyObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;
        existingAppPartyObj.Marital_Status__c = PortalConstants.MARITAL_STATUS_MARRIED;
        partyObjList.add(existingAppPartyObj);
        Database.insert(partyObjList,true);

        
        ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);
        ApplicationOriginationSetupTestHelper.createPrincipalParty(applicationObj,entityObj, existingApplicationObj);

        List<clcommon__Party__c> principalPartyList = [SELECT id,Street__c,
                                                                City__c, 
                                                                State__c, 
                                                                County__c, 
                                                                Dealer_Applicant_Relationship__c, 
                                                                Postal_Code__c, 
                                                                Mobile_Number__c, 
                                                                Home_Number__c, 
                                                                Work_Number__c, 
                                                                Marital_Status__c, 
                                                                Suffix__c
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Party_Types__c = 'PRINCIPAL'];

        List<clcommon__Party__c> principalPartyUpdateList = new List<clcommon__Party__c>();
        for(clcommon__party__c eachParty: principalPartyList){
            principalPartyUpdateList.add(ApplicationOriginationTestHelper.insertIndividualPartyDetails(eachParty, eachParty.Dealer_Applicant_Relationship__c));
        }
        Database.update(principalPartyUpdateList, true);
    }

    /**
    * @description delete the additional info parties
    * @author Rakesh Saraf | 11-11-2024 
    * @param applicationId 
    **/
    private static void updateAdditionalInfoParty(Id applicationId){

        List<clcommon__Party__c> partyList=[SELECT  Id, 
                                                    clcommon__Party_Types__c,
                                                    genesis__Application__c
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c = :applicationId AND 
                                            (clcommon__Party_Types__c IN (:PortalConstants.LANDOWNER_PARTY_NAME,
                                                                            :PortalConstants.SPOUSE_PARTY_NAME ,
                                                                            :PortalConstants.BUYER_PARTY_NAME ,
                                                                            :PortalConstants.INSURANCE_AGENT_PARTY_NAME))];
        List<clcommon__party__c> partyListToUpdate = new List<clcommon__party__c>();
        for(clcommon__Party__c eachParty: partyList){
            eachParty.genesis__Application__c = null;
            partyListToUpdate.add(eachParty);
        }
        Database.update(partyListToUpdate,true);

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 20-01-2025 
    * @param userObj 
    **/
    private static void setOwnerId(User userObj){
        List<Account> accountList = [SELECT id FROM Account LIMIT 10];
        List<AccountShare> accountShareList = new List<AccountShare>();
        for(Account eachAccount: accountList){
            AccountShare accountShare = new AccountShare(
                AccountId = eachAccount.Id,
                UserOrGroupId = userObj.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'Read'
            );
            accountShareList.add(accountShare);
        }
        Database.insert(accountShareList, true);
        
        List<Contact> contactList = [SELECT id FROM Contact LIMIT 10];
        List<ContactShare> contactShareList = new List<ContactShare>();
        for(Contact eachContact: contactList){
            ContactShare contactShare = new ContactShare(
                ContactId = eachContact.Id,
                UserOrGroupId = userObj.Id,
                ContactAccessLevel = 'Edit'
            );
            contactShareList.add(contactShare);
        }
        Database.insert(contactShareList, true);

        List<genesis__Business_Information__c> businessInfoList = [SELECT id, ownerId FROM genesis__Business_Information__c LIMIT 10];
        List<genesis__Business_Information__c> businessInfoListToUpdate = new List<genesis__Business_Information__c>();
        for(genesis__Business_Information__c businessInfoObj: businessInfoList){
            businessInfoObj.ownerId = userObj.Id;
            businessInfoListToUpdate.add(businessInfoObj);
        }
        Database.update(businessInfoListToUpdate, true);
    }

    /**
    * @description test if a different cl is the valid user to access the application
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testCheckInValidUser(){
        User clUserObj =  ApplicationOriginationTestHelper.getSystemAdminUser();
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.isValidUser(applicationObj.id);
            }
            catch(Exception e){
                System.assertEquals('User is not authorized to perform this operation.',e.getMessage(),'Assertion Unsuccessful');
            }
            Test.stopTest();
        }
        
    }

    /**
    * @description test if cl is the valid user to access the application
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testCheckIsValidUser(){
        // User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        
        genesis__Applications__c applicationObj=ApplicationOriginationTestHelper.getCFAApplication();

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.isValidUser(applicationObj.id);
            }
            catch(Exception e){
                System.assertEquals('User is not authorized to perform this operation.',e.getMessage(),'Assertion Unsuccessful');
            }
            Test.stopTest();
        }
        
    }

    /**
    * @description check for additional info for Proceed with the requirements of the tier
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationTierReq(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Proceed with the requirements for the tier';
        applicationObj.genesis__Credit_Rating__c = tierList[0].id;
        applicationObj.genesis__Credit_Rating__r = tierList[0];
        applicationObj.genesis__Credit_Rating__r.name = 'Tier 3';

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    clcommon__Collateral_Category__r.Name,
                                                                    Total_Acres__c,
                                                                    Producer_Share_Percent__c,
                                                                    Approved_Yield__c,
                                                                    Insurance_Plan__c,
                                                                    Percent_Coverage_Level__c,
                                                                    Percent_Fed__c,
                                                                    clcommon__Collateral_Type__c, 
                                                                    genesis__Application__c, 
                                                                    clcommon__Collateral_Code__c
                                                            FROM clcommon__Collateral__c 
                                                            WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);
        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id,
                                                        Marital_Status__c 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c =: borrowerAccount.id
                                                    LIMIT 1];


        List<clcommon__Party__c> principalPartyList=ApplicationOriginationTestHelper.getPrincipalPartyList(applicationObj.id);

        System.runAs(adminUser){
            Test.startTest();
            PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);

            List<clcommon__Collateral__c> collateralList=[Select id from clcommon__Collateral__c where genesis__Application__c=:applicationObj.id];
            System.assert(collateralList.size()>0,'Assertion unsuccessfull');
            Test.stopTest();

        }
    }

    /**
    * @description check for additional info for request second look
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationForRequestSecondLook(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id,
                                                        Marital_Status__c 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c =: borrowerAccount.id
                                                    LIMIT 1];

        List<clcommon__Party__c> principalPartyList=ApplicationOriginationTestHelper.getPrincipalPartyList(applicationObj.id);

        System.runAs(adminUser){
            Test.startTest();
            
            PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);

            List<clcommon__Collateral__c> collateralList=[Select id from clcommon__Collateral__c where genesis__Application__c=:applicationObj.id];
            System.assert(collateralList.size()>0,'Assertion unsuccessfull');
            Test.stopTest();

        }
    }

    /**
    * @description check for additional info for business
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationForBuisness(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();
        
        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c(Id = borrowerAccount.clcommon__Legal_Entity_Type__c);
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj, true); 
        borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                        Marital_Status__c,
                                                        clcommon__Account__c,
                                                        clcommon__Type__r.name
                                                    FROM clcommon__Party__c
                                                    WHERE (clcommon__Type__r.name =: 'BORROWER'
                                                            OR
                                                            clcommon__Type__r.name =: 'PRINCIPAL')];
        List<clcommon__Party__c> borrowerPartyList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> principalPartyList = new List<clcommon__Party__c>();
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Type__r.Name == 'BORROWER'){
                borrowerPartyList.add(eachParty);
            }else if(eachParty.clcommon__Type__r.Name == 'PRINCIPAL'){
                eachParty.Marital_Status__c = PortalConstants.MARITAL_STATUS_MARRIED;
                principalPartyList.add(eachParty);
            }
        }

        System.runAs(adminUser){
            Test.startTest();
            // List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicantInfo
            boolean isException =false;
            try{
                PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);
                                                                                            
            }catch(Exception e){
                isException = true;
            }
            System.assert(!isException,'Assertion unsuccessfull');
            Test.stopTest();
        }
    }

    /**
    * @description check for additional info for business no spouse
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationForBuisnessNoSpouse(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();
        
        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c(Id = borrowerAccount.clcommon__Legal_Entity_Type__c);
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj, true); 
        borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                        genesis__Application__c,
                                                        Marital_Status__c,
                                                        clcommon__Account__c,
                                                        clcommon__Type__r.name
                                                    FROM clcommon__Party__c
                                                    WHERE (clcommon__Type__r.name =: 'BORROWER'
                                                            OR
                                                            clcommon__Type__r.name =: 'PRINCIPAL')
                                                            OR
                                                            clcommon__Type__r.name =: PortalConstants.SPOUSE_PARTY_NAME];
        List<clcommon__Party__c> borrowerPartyList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> principalPartyList = new List<clcommon__Party__c>();
        clcommon__party__c spousePartyObj;
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Type__r.Name == 'BORROWER'){
                borrowerPartyList.add(eachParty);
            }else if(eachParty.clcommon__Type__r.Name == 'PRINCIPAL'){
                eachParty.Marital_Status__c = PortalConstants.MARITAL_STATUS_MARRIED;
                principalPartyList.add(eachParty);
            }else if(eachParty.clcommon__Type__r.Name == PortalConstants.SPOUSE_PARTY_NAME){
                spousePartyObj = eachParty;
            }
        }
        spousePartyObj.genesis__Application__c = null;
        Database.update(spousePartyObj, true);

        System.runAs(adminUser){
            Test.startTest();
            // List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicantInfo
            boolean isException =false;
            try{
                PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);
                                                                                            
            }catch(Exception e){
                isException = true;
            }
            System.assert(isException,'Assertion unsuccessfull');
            Test.stopTest();
        }
    }

    /**
    * @description check for additional info for request second look and no score applicant
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationForNoScoreApplicant(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        Account principalAccount=ApplicationOriginationTestHelper.getPrincipalAccount();

        borrowerAccount.Score_1__c='9002';
        principalAccount.Score_1__c='9003';
        Database.update(new List<Account>{borrowerAccount,principalAccount},true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

        List<clcommon__Party__c> borrowerPartyList = [SELECT Id,
                                                        Marital_Status__c 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c =: borrowerAccount.id
                                                    LIMIT 1];

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        
        Database.delete(collateralObjList,true);

        List<clcommon__Party__c> principalPartyList=ApplicationOriginationTestHelper.getPrincipalPartyList(applicationObj.id);

        System.runAs(adminUser){
            Test.startTest();
            PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);

            List<clcommon__Collateral__c> collateralList=[Select id from clcommon__Collateral__c where genesis__Application__c=:applicationObj.id];
            System.assert(collateralList.isEmpty(),'Assertion unsuccessfull');
            Test.stopTest();

        }

    }

    /**
    * @description check for additional info for customized loan
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationForCustomizeLoan(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();
        //setOwnerId(adminUser);

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Customize';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

        List<clcommon__Party__c> borrowerPartyList = [SELECT Id,
                                                        Marital_Status__c 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c =: borrowerAccount.id
                                                    LIMIT 1];

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        
        Database.delete(collateralObjList,true);

        List<clcommon__Party__c> principalPartyList=ApplicationOriginationTestHelper.getPrincipalPartyList(applicationObj.id);

        System.runAs(adminUser){
            Test.startTest();
            PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);

            List<clcommon__Collateral__c> collateralList=[SELECT id FROM clcommon__Collateral__c WHERE genesis__Application__c=:applicationObj.id];
            System.assert(collateralList.isEmpty(),'Assertion unsuccessfull');
            Test.stopTest();

        }
    }

    /**
    * @description check for additional info for not enough collateral value
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationInsufficientCollaterals(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id,
                                                        Marital_Status__c 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c =: borrowerAccount.id
                                                    LIMIT 1];
        
        List<clcommon__Party__c> principalPartyList=ApplicationOriginationTestHelper.getPrincipalPartyList(applicationObj.id);

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);
            }
            catch(Exception e){
                System.assertEquals('Please add collaterals to match the loan amount',e.getMessage(),'Assertion Unsuccessful');
            }
            Test.stopTest();
        }
    }

    /**
    * @description check for additional info where additional info parties are deleted
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testAdditionalInfoValidationNoAdditonalInfoParty(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();
        //setOwnerId(adminUser);

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        Contact borrowerContact=ApplicationOriginationTestHelper.getBorrowerContact();
        borrowerContact.clcommon__Marital_Status__c='Married';
        Database.update(borrowerContact,true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';
        applicationObj.genesis__Credit_Rating__c = tierList[0].Id;
        Database.update(applicationObj, true);

         List<clcommon__Party__c> borrowerPartyList = [SELECT Id,
                                                        Marital_Status__c 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c =: borrowerAccount.id
                                                    LIMIT 1];

        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);

        updateAdditionalInfoParty(applicationObj.id);

        List<clcommon__Party__c> principalPartyList=ApplicationOriginationTestHelper.getPrincipalPartyList(applicationObj.id);

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                                PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                                PortalConstants.KEY_SHOULD_DENY=>false,
                                                                                                PortalConstants.ACCOUNT_KEY=>borrowerAccount,
                                                                                                PortalConstants.CONTACT_KEY=>borrowerContact,
                                                                                                PortalConstants.KEY_PARTY=>borrowerPartyList[0]
                                                                                            },principalPartyList);
            }
            catch(Exception e){
                System.assert(e.getMessage()!=null,'Assertion Unsuccessful');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test for evergreen when the signing method is missing
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testSigningMethodMissingNull(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Is_Evergreen__c=false;
        applicationObj.Signing_Method__c = null;

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validationForEvergreenApplication(applicationObj, false);
            }
            catch(Exception e){
                System.assertEquals('Please complete the signature process on the Applicant Signature tab prior to submitting this application.',e.getMessage(),'Asssertion Unsuccesful');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test for evergreen when the signing method is missing
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testSigningMethodMissing(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Is_Evergreen__c=false;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = false;

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validationForEvergreenApplication(applicationObj, false);
            }
            catch(Exception e){
                System.assertEquals('Please complete the signature process on the Applicant Signature tab prior to submitting this application.',e.getMessage(),'Asssertion Unsuccesful');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test for evergreen when the application is evergreen and tier 2
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testEvergreenAppTierTwo(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__r = tierList[0];
        applicationObj.Is_Evergreen__c=true;
        applicationObj.genesis__Credit_Rating__r.name='Tier 2';

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validationForEvergreenApplication(applicationObj, false);
            }
            catch(Exception e){
                System.assertEquals('Please score the application prior to selecting submit.',e.getMessage(),'Asssertion Unsuccesful');
            }
            Test.stopTest();
        }
    }
    
    /**
    * @description test for evergreen when the application is evergreen and tier 2
    * @author Rakesh Saraf | 12-04-2024 
    **/
    @isTest
    private static void testEvergreenAppTierTwoBizInfoProvided(){
        User adminUser = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> tierList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__r = tierList[0];
        applicationObj.Is_Evergreen__c=true;
        applicationObj.genesis__Credit_Rating__r.name='Tier 2';
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c='Provided';

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validationForEvergreenApplication(applicationObj, false);
            }
            catch(Exception e){
                System.assertEquals('Please score the application prior to selecting submit.',e.getMessage(),'Asssertion Unsuccesful');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test for partner program of dealer
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testvalidteDealerPartnerProgram(){
        User adminUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        Account dealerAcc=ApplicationOriginationTestHelper.getDealerAccoount();
        dealerAcc.CFA_Partner_Program__c=null;
        Database.update(dealerAcc,true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        System.runAs(adminUserObj) {
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validateDealerPartnerProgram(applicationObj);
            }catch(Exception e){
                System.assertEquals('Something went wrong',e.getMessage(), 'Assertion unsuccessful!');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test for null paramters passed
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    private static void testvalidteApplicationScored(){
        User adminUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c='Request second look';

        System.runAs(adminUserObj) {
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validateApplicationScored(applicationObj);
            }catch(Exception e){
                System.assertEquals('Application must be scored prior to submitting',e.getMessage(), 'Assertion unsuccessful!');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test if the applicant details are  valid or not.
    * @author Rakesh Saraf | 12-04-2024 
    **/
    @isTest
    private static void testApplicantInfoValidation(){

        Id borrowerAccountId;
        Id borrowerContactId;
        Id borrowerBInfoId;
        List<Id> principalAccIdList=new List<Id>();
        List<Id> principalConIdList=new List<Id>();
        List<Id> principalBIIdList=new List<Id>();

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        setOwnerId(clUserObj);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        List<clcommon__Party__c> applicantPartyList=[SELECT ID,
                                                 clcommon__Account__c,
                                                 clcommon__Account__r.genesis__Business_Information__c,
                                                 clcommon__Contact__c,
                                                 clcommon__Party_Types__c,
                                                 Street__c, City__c, State__c, County__c, Dealer_Applicant_Relationship__c, Postal_Code__c, Mobile_Number__c, Home_Number__c, Work_Number__c, Marital_Status__c, Suffix__c
                                         FROM clcommon__Party__c
                                         WHERE genesis__Application__c =: applicationObj.id
                                         AND clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,:PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__Party__c eachParty: applicantPartyList){
            if(eachParty.clcommon__Party_Types__c==PortalConstants.PRINCIPAL_PARTY_NAME){
                principalAccIdList.add(eachParty.clcommon__Account__c);
                principalConIdList.add(eachParty.clcommon__Contact__c);
                principalBIIdList.add(eachParty.clcommon__Account__r.genesis__Business_Information__c);
            }
            else{
                borrowerAccountId=eachParty.clcommon__Account__c;
                borrowerContactId=eachParty.clcommon__Contact__c;
                borrowerBInfoId=eachParty.clcommon__Account__r.genesis__Business_Information__c;
            }
        }

        System.runAs(clUserObj) {
            Test.startTest();
            try{
                PortalAppSubmissionValidationUtil.validateApplicationInfoForApplicants(new List<genesis__Applications__c>{applicationObj},
                                                                                        new Map<String,Id>{ PortalConstants.ACCOUNT_KEY=>borrowerAccountId,
                                                                                                            PortalConstants.CONTACT_KEY=>borrowerContactId,
                                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>borrowerBInfoId},
                                                                                        new Map<String, List<Id>>{PortalConstants.ACCOUNT_KEY=>principalAccIdList,
                                                                                                                  PortalConstants.CONTACT_KEY=>principalConIdList,
                                                                                                                  PortalConstants.BUSINESS_INFO_OBJ_KEY=>principalBIIdList}
                                                                                      );
            }catch(Exception e){
                System.assert(e.getMessage()!=null, 'Assertion unsuccessful!');
            }
            Test.stopTest();
        }
    }

    
}