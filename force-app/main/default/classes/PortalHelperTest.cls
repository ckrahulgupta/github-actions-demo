/**
 * @description       : Test class for PortalHelper
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-24-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalHelperTest {

    private static final String KEY_BUSINESS_INFO_LIST = 'businessInfoList';
    private static final String KEY_BORROWER_ACCOUNT_LIST = 'borrowerAccountList';
    private static final String KEY_BORROWER_CONTACT_LIST = 'contactList';
    private static final String KEY_APPLICATION_LIST = 'applicationList';
    private static final String KEY_PARTY_LIST = 'partyList';
    private static final String KEY_PARTY_TYPE_LIST = 'partyTypeList';
    private static final String KEY_LEGAL_ENTITY_LIST = 'legalEntityList';
    private static final String KEY_CONTENT_DOCUMENT_LIST = 'contentDocumentList';
    private static final String KEY_CONTENT_VERSION_LIST = 'contentVersionList';
    private static final String KEY_COLLATERAL_LIST = 'collateralList';
    private static final String KEY_RATE_CARD_HEADER_LIST = 'rateCardHeaderList';
    private static final String KEY_RATE_CARD_DETAIL_LIST = 'rateCardDetailList';
    private static final String KEY_COLLATERAL_CATEGORY_LIST = 'collateralCategoryList';
    private static final String KEY_CUSTOM_EXCEPTION_TEXT = 'This is a test custom exception';
    private static final String KEY_CUSTOM_EXCEPTION = 'CustomException';
    private static final String GROWER_NAME = 'Jasmine Albin';
    private static final String RATE_CARD_DESCRIPTION = 'This is a test rate card setup detail for a test my porgram of a test Account';
    private static final String CERTIFIED_LENDER_NAME = 'Ross Geller';
    private static final String KEY_DATE_FORMAT = 'yyyy-MM-dd';
    private static final String KEY_ID = 'id';
    private static final String KEY_COLLATERAL_FIELD = 'clcommon__Collateral__c';
    private static final String KEY_TOTAL_ACRES_FIELD = 'Total_Acres__c';
    private static final String KEY_PRODUCER_SHARE_FIELD = 'Producer_Share_Percent__c';
    private static final String KEY_APPROVED_YIELD_FIELD = 'Approved_Yield__c';
    private static final String KEY_PERCENT_FED_FIELD = 'Percent_Fed__c';
    private static final String KEY_COLLATERAL_CATEGORY_FIELD = 'clcommon__Collateral_Category__c';
    private static final String KEY_INSURANCE_PLAN_FIELD = 'Insurance_Plan__c';
    private static final String KEY_PERCENT_COVERAGE_LEVEL_FIELD = 'Percent_Coverage_Level__c';
    private static final String KEY_BUSINESS_INFO_FIELD = 'genesis__Business_Information__c';
    private static final String KEY_CONTACT_FIELD = 'clcommon__Contact__c';
    private static final String KEY_CONTACT_LASTNAME_FIELD = 'clcommon__Contact__r.LastName';
    private static final String KEY_PARTY_ID_FIELD = 'clcommon__Party__r.Id';
    private static final String KEY_ACCOUNT_FIELD = 'clcommon__Account__c';
    private static final String KEY_ACCOUNT_NAME_FIELD = 'clcommon__Account__r.Name';
    private static final String KEY_PARTY_FIELD = 'clcommon__Party__c';
    private static final String EMAIL_TEMPLATE_TO_GROWER = 'Incomplete Application Open for More Than 24 Hours (Sent from SF to Grower)';
    private static final String NEW_APPLICANT ='newApplicant';
    private static final String SAVE_AND_EXIT = 'SaveAndExist';

    
    /**
    * @description - Creating test data
    * @author Sk Minsar | 03-11-2025 
    **/
    @TestSetup
    static void makeData() {
        
        //creating application, party, roles, relationships
        ApplicationOriginationSetupTestHelper.createTestSetup();

        List<genesis__Applications__c> applicationList = [
            SELECT Id, Dealer_Name__c, genesis__Loan_Number__c
            FROM genesis__Applications__c
            WHERE Loan_Id__c = '139000'
            ORDER BY CreatedDate
            LIMIT 1
        ];

        List<Account> dealerAccountList = [
            SELECT Id
            FROM Account
            WHERE Id =: applicationList[0].Dealer_Name__c
            LIMIT 1
        ];

        //creating collaterals, rate cards
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationList[0], dealerAccountList[0]);

        //creating contentversion
        ContentVersion contentVerAgreementObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.AGREEMENT_FILE_NAME);
        Database.insert(contentVerAgreementObj,true);

        //creating content Document
        ContentDocument contentDocAgreementObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
 
        //creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAgreementObj.id, applicationList[0].Id);
        Database.insert(contentDocLinkAgrmttObj,true);

        //creating signed credit agreement
        clcommon__document_category__c docCategorySigned = ApplicationOriginationTestHelper.createDocCategory(applicationList[0].Id, PortalConstants.SIGNED_AGREEMENT_TASK);
        Database.insert(docCategorySigned,true);

    }

    /**
    * @description - This method queries and returns all the necessary data
    * @author Sk Minsar | 03-05-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){

        List<genesis__Business_Information__c> businessInfoList =[SELECT Id FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '339814629' LIMIT 1];

        List<Account> accountList = [SELECT Id,Name,CIF_Number__c,clcommon__Email__c FROM Account WHERE Name = :GROWER_NAME AND genesis__Business_Information__c= :businessInfoList[0].Id LIMIT 1];

        List<Contact> contactList = [SELECT Id,AccountId,Account.Name,FirstName,LastName,MobilePhone,HomePhone,Phone,Email,Confirm_Email__c,genesis__SSN__c,Confirm_SSN__c FROM Contact WHERE AccountId = : accountList[0].Id];
        
        List<genesis__Applications__c> applicationList = [SELECT Id, genesis__Loan_Number__c, genesis__Account__r.CIF_Number__c,genesis__Loan_Amount__c,genesis__Maturity_Date__c,genesis__Account__c,Dealer_Name__c,Dealer_Name__r.Coop_Type__c, genesis__Account__r.Name FROM genesis__Applications__c WHERE Loan_Id__c = '139000' ORDER BY CreatedDate LIMIT 1];

        List<clcommon__Party__c> partyList = [SELECT Id, genesis__Application__r.genesis__Loan_Number__c, clcommon__Type__c,clcommon__Account__r.Name, clcommon__Account__r.CIF_Number__c, genesis__Application__r.genesis__status__c,NTB_Generated__c,genesis__Application__c FROM clcommon__Party__c WHERE genesis__Application__c = :applicationList[0].Id AND clcommon__Account__r.Name= :GROWER_NAME LIMIT 1];

        List<clcommon__Party_Type__c> partyTypeList=  [SELECT id,Name FROM clcommon__Party_Type__c WHERE id=:partyList[0].clcommon__Type__c];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, Name FROM clcommon__Legal_Entity__c LIMIT 100];

        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];

        List<ContentVersion> contenVersionList = [SELECT Id FROM ContentVersion WHERE Title= :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];

        List<clcommon__Collateral__c> objCollateralList = [SELECT Percent_Coverage_Level__c,Percent_Fed__c,Producer_Share_Percent__c,clcommon__Collateral_Category__c FROM clcommon__Collateral__c WHERE genesis__Application__c = :applicationList[0].Id LIMIT 1];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Price_Per_Unit_1__c = 10.85 LIMIT 1];

        List<genesis__rate_card_setup_header__c> rateCardList = [SELECT Id, Name, Status__c, Account__r.Name FROM genesis__rate_card_setup_header__c WHERE Name = 'My Test Program 99' LIMIT 1];

        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,Start_Date__c,End_Date__c, genesis__Enabled_flag__c,genesis__rate_card_setup_header__c, Special_Term_Reference__c FROM genesis__Rate_Card_Setup_Detail__c WHERE genesis__rate_card_setup_header__c = :rateCardList[0].Id AND Description__c = :RATE_CARD_DESCRIPTION LIMIT 1];

        return new Map<String, Object>{
            KEY_BUSINESS_INFO_LIST => businessInfoList,
            KEY_BORROWER_ACCOUNT_LIST => accountList,
            KEY_BORROWER_CONTACT_LIST => contactList,
            KEY_APPLICATION_LIST => applicationList,
            KEY_PARTY_LIST => partyList,
            KEY_PARTY_TYPE_LIST => partyTypeList,
            KEY_LEGAL_ENTITY_LIST => legalEntityList,
            KEY_CONTENT_DOCUMENT_LIST => contentDocumentList,
            KEY_CONTENT_VERSION_LIST => contenVersionList,
            KEY_COLLATERAL_LIST => objCollateralList,
            KEY_RATE_CARD_HEADER_LIST => rateCardList,
            KEY_RATE_CARD_DETAIL_LIST => rateCardDetailList,
            KEY_COLLATERAL_CATEGORY_LIST => collateralCategoryList
        };
    }

    /**
    * @description - Fetch logs
    * @author Sk Minsar | 03-13-2025 
    * @param exceptionName 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getLogsByName(String exceptionName){
        return [SELECT Name, clcommon__Message__c, clcommon__Time__c 
                                        FROM clcommon__Log__c 
                                        WHERE Name = :exceptionName LIMIT :PortalConstants.TWO_HUNDRED_VALUE];
    }

    /**
    * @description - Test LoggedInuser
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testLoggedInUser(){

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                List<User> loggedInUser = PortalHelper.getLoggedInUser();
                System.assertEquals(PortalConstants.TRUE_VALUE, loggedInUser.size()> PortalConstants.ZERO_VALUE, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(UserInfo.getUserId(), loggedInUser[0].Id, PortalConstants.ASSERTION_FAILED);
            Test.stopTest(); 
        }

    }

    /**
    * @description - validate loan number
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testUpdateLoanNumber(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        objAccount.CIF_Number__c='897679';
        Database.update(objAccount,true);
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party_Type__c partyTypeObj= ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.BORROWER_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        mapOfpartyType.put(PortalConstants.BORROWER_PARTY_NAME,partyTypeObj.Id);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.updateLoanNumber(currAppObj.Id,SAVE_AND_EXIT,mapOfpartyType);
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<genesis__Applications__c> applicationList = [SELECT Id, genesis__Loan_Number__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' ORDER BY CreatedDate LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description - validate new Applicant loan number
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testNewApplicantLoanNumber(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        objAccount.CIF_Number__c='897679';
        Database.update(objAccount,true);
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party_Type__c partyTypeObj =  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        partyTypeObj.Name=PortalConstants.BORROWER_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        mapOfpartyType.put(PortalConstants.BORROWER_PARTY_NAME,partyTypeObj.Id);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.updateLoanNumber(currAppObj.Id,NEW_APPLICANT,mapOfpartyType);
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<genesis__Applications__c> applicationList = [SELECT Id, genesis__Loan_Number__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' ORDER BY CreatedDate LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description - validate doc category name
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testGetDocumentCategoryName(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];       
        ContentDocument contentDocumentObj = ((List<ContentDocument>)dataMap.get(KEY_CONTENT_DOCUMENT_LIST))[0];       
        ContentVersion contenVersionObj = ((List<ContentVersion>)dataMap.get(KEY_CONTENT_VERSION_LIST))[0];

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getDocumentCategoryName(PortalConstants.AGREEMENT_FILE_NAME,contenVersionObj.Id,contentDocumentObj.Id,currAppObj.Id, PortalConstants.SIGNED_AGREEMENT_TASK);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = [SELECT Id, Name, clcommon__Content_Version_Id__c, clcommon__Content_Document_Id__c FROM clcommon__Category_Attachment_Association__c WHERE clcommon__Content_Document_Id__c = :contentDocumentObj.Id];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, categoryAttachmentList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.AGREEMENT_FILE_NAME, categoryAttachmentList[0].Name, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(contenVersionObj.Id, categoryAttachmentList[0].clcommon__Content_Version_Id__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(contentDocumentObj.Id, categoryAttachmentList[0].clcommon__Content_Document_Id__c, PortalConstants.ASSERTION_FAILED);  
            Test.stopTest();
        } 

    }

    /**
    * @description - validate send email on deleting pending payment
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testSendEmailOnDeletingPendingPayment(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.sendEmailOnDeletingPendingPayment(currAppObj.genesis__Loan_Number__c, currAppObj.genesis__Account__r.Name,'500','2026-03-15');
                }
                catch(CustomException e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        } 

    }

    /**
    * @description - validate send email to grower
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testSendEmailToGrower(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.sendEmailToGrower('Paul Wrapson','2023-03-15','paul.wrapson@yopmail.com','KS','KL','Caroline Patrick');
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }  

    }
    
    /**
    * @description - check the legal Entity Type
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testLegalEntityType(){

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                Map<String, Id> legalEntity = PortalHelper.getLegalEntityMap();
                System.assertEquals(PortalConstants.TRUE_VALUE, legalEntity.size()> PortalConstants.ZERO_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest(); 
        }

    }
    
    /**
    * @description - check the party type
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testPartyType(){
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                Map<String, Id> partyType = PortalHelper.getPartyTypeMap();
                System.assertEquals(PortalConstants.TRUE_VALUE, partyType.size()> PortalConstants.ZERO_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }

    /**
    * @description - test collateral Details
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testSaveApplicationCollateral(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Collateral__c objCollateral = ((List<clcommon__Collateral__c>)dataMap.get(KEY_COLLATERAL_LIST))[0];

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveApplicationCollateral(objCollateral,currAppObj.Id);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE; 
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }

    /**
    * @description - test collateral Details with null application Id
    * @author Sk Minsar | 03-11-2025 
    **/
    @isTest
    public static void testSaveApplicationCollateralNullAppIdEx(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Collateral__c objCollateral = ((List<clcommon__Collateral__c>)dataMap.get(KEY_COLLATERAL_LIST))[0];

        System.runAs(ApplicationOriginationTestHelper.getCertifiedLenderUser(CERTIFIED_LENDER_NAME)){
            Test.startTest();
                try{
                    PortalHelper.saveApplicationCollateral(objCollateral, null);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE; 
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }

    /**
    * @description - test collateral Details with null collateral Id
    * @author Sk Minsar | 03-11-2025 
    **/
    @isTest
    public static void testSaveApplicationCollateralNullCollateralId(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Collateral__c objCollateral = new clcommon__Collateral__c();

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveApplicationCollateral(objCollateral, currAppObj.Id);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE; 
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id , objCollateral.genesis__Application__c, PortalConstants.ASSERTION_FAILED);

            Test.stopTest();
        }

    }
    
    /**
    * @description - test blank Collateral Id
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testBlankCollateralId(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Collateral__c objCollateral = new clcommon__Collateral__c();
        objCollateral.Id = null;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveApplicationCollateral(objCollateral,currAppObj.Id);
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
                System.assertEquals(currAppObj.Id , objCollateral.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - validate Collateral User
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testValidCollateralUser(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Collateral__c objCollateral = ((List<clcommon__Collateral__c>)dataMap.get(KEY_COLLATERAL_LIST))[0];

        System.runAs(ApplicationOriginationTestHelper.getCertifiedLenderUser(CERTIFIED_LENDER_NAME)){
            Test.startTest();
                try{
                    PortalHelper.saveApplicationCollateral(objCollateral,currAppObj.Id);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }
    
    /**
    * @description - validate null Collateral Details
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testNullCollateralDetails(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> mapOfCollateral = new Map<String, Object>();
        clcommon__Collateral__c objCollateral = ((List<clcommon__Collateral__c>)dataMap.get(KEY_COLLATERAL_LIST))[0];
        mapOfCollateral.put(KEY_COLLATERAL_FIELD,objCollateral);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
            clcommon__collateral__c collateralDetails;
                try{    
                    collateralDetails = PortalHelper.getCollateralDetails(mapOfCollateral);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, collateralDetails != null, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
        
    }
    
    /**
    * @description - test fetch Collateral Details
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testGetCollateralDetails(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> mapOfCollateral = new Map<String, Object>();
        clcommon__Collateral__c objCollateral = ((List<clcommon__Collateral__c>)dataMap.get(KEY_COLLATERAL_LIST))[0];

        mapOfCollateral.put(KEY_COLLATERAL_FIELD,objCollateral);
        mapOfCollateral.put(PortalConstants.ID_KEY,objCollateral.Id);
        mapOfCollateral.put(KEY_TOTAL_ACRES_FIELD,'768');
        mapOfCollateral.put(KEY_PRODUCER_SHARE_FIELD,objCollateral.Producer_Share_Percent__c);
        mapOfCollateral.put(KEY_APPROVED_YIELD_FIELD,'343');
        mapOfCollateral.put(KEY_PERCENT_FED_FIELD,objCollateral.Percent_Fed__c);
        mapOfCollateral.put(KEY_COLLATERAL_CATEGORY_FIELD,objCollateral.clcommon__Collateral_Category__c);
        mapOfCollateral.put(KEY_INSURANCE_PLAN_FIELD,'YP');
        mapOfCollateral.put(KEY_PERCENT_COVERAGE_LEVEL_FIELD,objCollateral.Percent_Coverage_Level__c);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            clcommon__collateral__c collateralDetails;
            Test.startTest();
                try{
                    collateralDetails = PortalHelper.getCollateralDetails(mapOfCollateral);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(objCollateral.Id, collateralDetails.Id, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(768.00, collateralDetails.Total_Acres__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(objCollateral.Producer_Share_Percent__c, collateralDetails.Producer_Share_Percent__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(343.00, collateralDetails.Approved_Yield__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(objCollateral.Percent_Fed__c, collateralDetails.Percent_Fed__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(objCollateral.clcommon__Collateral_Category__c, collateralDetails.clcommon__Collateral_Category__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('YP', collateralDetails.Insurance_Plan__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(objCollateral.Percent_Coverage_Level__c, collateralDetails.Percent_Coverage_Level__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('Commodity', collateralDetails.clcommon__Collateral_Name__c, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }
    
    /**
    * @description - check Additional Info
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testSaveAdditionalInfoDetails(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> response = new Map<String, Object>();
        genesis__Business_Information__c businessInfoObj = ((List<genesis__Business_Information__c>)dataMap.get(KEY_BUSINESS_INFO_LIST))[0];
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        Contact objContact = ((List<Contact>)dataMap.get(KEY_BORROWER_CONTACT_LIST))[0];
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        clcommon__Party_Type__c partyTypeObj=  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.BUYER_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        response.put(KEY_BUSINESS_INFO_FIELD,businessInfoObj);
        response.put(KEY_CONTACT_FIELD,objContact.Id);
        response.put(KEY_CONTACT_LASTNAME_FIELD,objContact.LastName);
        response.put(KEY_PARTY_FIELD,partyObj);
        response.put(KEY_PARTY_ID_FIELD,partyObj.Id);
        response.put(KEY_ACCOUNT_FIELD,objAccount.Id);
        response.put(KEY_ACCOUNT_NAME_FIELD,objAccount.Name);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveAdditionalInfoDetails(response,currAppObj.Id, PortalConstants.BUYER_PARTY_NAME);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Party__c> partyList = [SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Party_Types__c FROM clcommon__Party__c WHERE genesis__Application__c = :currAppObj.Id AND clcommon__Party_Types__c =: PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.BUYER_PARTY_NAME, partyList[0].clcommon__Party_Types__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id, partyList[0].genesis__Application__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Account__c != null, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Contact__c != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - check Additional Info for single word account name
    * @author Sk Minsar | 03-11-2025 
    **/
    @isTest
    public static void testSaveAdditionalInfoDetailsForLastName(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> response = new Map<String, Object>();
        genesis__Business_Information__c businessInfoObj = ((List<genesis__Business_Information__c>)dataMap.get(KEY_BUSINESS_INFO_LIST))[0];
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        Contact objContact = ((List<Contact>)dataMap.get(KEY_BORROWER_CONTACT_LIST))[0];
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        clcommon__Party_Type__c partyTypeObj=  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.BUYER_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        response.put(KEY_BUSINESS_INFO_FIELD,businessInfoObj);
        response.put(KEY_CONTACT_FIELD,objContact.Id);
        response.put(KEY_CONTACT_LASTNAME_FIELD,objContact.LastName);
        response.put(KEY_PARTY_FIELD,partyObj);
        response.put(KEY_PARTY_ID_FIELD,partyObj.Id);
        response.put(KEY_ACCOUNT_FIELD,objAccount.Id);
        response.put(KEY_ACCOUNT_NAME_FIELD,objContact.LastName);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveAdditionalInfoDetails(response,currAppObj.Id, PortalConstants.BUYER_PARTY_NAME);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Party__c> partyList = [SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Party_Types__c FROM clcommon__Party__c WHERE genesis__Application__c = :currAppObj.Id AND clcommon__Party_Types__c =: PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.BUYER_PARTY_NAME, partyList[0].clcommon__Party_Types__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id, partyList[0].genesis__Application__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Account__c != null, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Contact__c != null, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }

    /**
    * @description - check Additional Info with null contact
    * @author Sk Minsar | 03-11-2025 
    **/
    @isTest
    public static void testSaveAdditionalInfoDetailsNullContact(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> response = new Map<String, Object>();
        genesis__Business_Information__c businessInfoObj = ((List<genesis__Business_Information__c>)dataMap.get(KEY_BUSINESS_INFO_LIST))[0];
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        Contact objContact = ((List<Contact>)dataMap.get(KEY_BORROWER_CONTACT_LIST))[0];
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        clcommon__Party_Type__c partyTypeObj=  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.BUYER_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        response.put(KEY_BUSINESS_INFO_FIELD,businessInfoObj);
        response.put(KEY_CONTACT_FIELD, null);
        response.put(KEY_CONTACT_LASTNAME_FIELD,objContact.LastName);
        response.put(KEY_PARTY_FIELD,partyObj);
        response.put(KEY_PARTY_ID_FIELD,partyObj.Id);
        response.put(KEY_ACCOUNT_FIELD,objAccount.Id);
        response.put(KEY_ACCOUNT_NAME_FIELD,objAccount.Name);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveAdditionalInfoDetails(response,currAppObj.Id, PortalConstants.BUYER_PARTY_NAME);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Party__c> partyList = [SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Party_Types__c FROM clcommon__Party__c WHERE genesis__Application__c = :currAppObj.Id AND clcommon__Party_Types__c =: PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.BUYER_PARTY_NAME, partyList[0].clcommon__Party_Types__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id, partyList[0].genesis__Application__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Account__c != null, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Contact__c != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - check Additional Info with new Account
    * @author Sk Minsar | 03-11-2025 
    **/
    @isTest
    public static void testSaveAdditionalInfoDetailsNullAccount(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> response = new Map<String, Object>();
        genesis__Business_Information__c businessInfoObj = ((List<genesis__Business_Information__c>)dataMap.get(KEY_BUSINESS_INFO_LIST))[0];
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        Contact objContact = ((List<Contact>)dataMap.get(KEY_BORROWER_CONTACT_LIST))[0];
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        clcommon__Party_Type__c partyTypeObj=  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.BUYER_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        response.put(KEY_BUSINESS_INFO_FIELD,businessInfoObj);
        response.put(KEY_CONTACT_FIELD,objContact.Id);
        response.put(KEY_CONTACT_LASTNAME_FIELD,objContact.LastName);
        response.put(KEY_PARTY_FIELD,partyObj);
        response.put(KEY_PARTY_ID_FIELD,partyObj.Id);
        response.put(KEY_ACCOUNT_FIELD, null);
        response.put(KEY_ACCOUNT_NAME_FIELD,objAccount.Name);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveAdditionalInfoDetails(response,currAppObj.Id, PortalConstants.BUYER_PARTY_NAME);
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Party__c> partyList = [SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Party_Types__c FROM clcommon__Party__c WHERE genesis__Application__c = :currAppObj.Id AND clcommon__Party_Types__c =: PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.BUYER_PARTY_NAME, partyList[0].clcommon__Party_Types__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id, partyList[0].genesis__Application__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Account__c != null, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Contact__c != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - check Additional Info with party Id
    * @author Sk Minsar | 03-11-2025 
    **/
    @isTest
    public static void testSaveAdditionalInfoDetailsWithId(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> response = new Map<String, Object>();
        genesis__Business_Information__c businessInfoObj = ((List<genesis__Business_Information__c>)dataMap.get(KEY_BUSINESS_INFO_LIST))[0];
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        Contact objContact = ((List<Contact>)dataMap.get(KEY_BORROWER_CONTACT_LIST))[0];
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        clcommon__Party_Type__c partyTypeObj=  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.BUYER_PARTY_NAME;
        Database.update(partyTypeObj,true);
        response.put(KEY_ID, partyObj.Id);                                
        response.put(KEY_BUSINESS_INFO_FIELD,businessInfoObj);
        response.put(KEY_CONTACT_FIELD,objContact.Id);
        response.put(KEY_CONTACT_LASTNAME_FIELD,objContact.LastName);
        response.put(KEY_PARTY_FIELD,partyObj);
        response.put(KEY_PARTY_ID_FIELD,partyObj.Id);
        response.put(KEY_ACCOUNT_FIELD,objAccount.Id);
        response.put(KEY_ACCOUNT_NAME_FIELD,objAccount.Name);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveAdditionalInfoDetails(response,currAppObj.Id, PortalConstants.BUYER_PARTY_NAME);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Party__c> partyList = [SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Party_Types__c FROM clcommon__Party__c WHERE genesis__Application__c = :currAppObj.Id AND clcommon__Party_Types__c =: PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.BUYER_PARTY_NAME, partyList[0].clcommon__Party_Types__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id, partyList[0].genesis__Application__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Account__c != null, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Contact__c != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description - test Spousal Additional Info
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testSaveSpouseAdditionalInfoDetails(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> response = new Map<String, Object>();
        genesis__Business_Information__c businessInfoObj = ((List<genesis__Business_Information__c>)dataMap.get(KEY_BUSINESS_INFO_LIST))[0];
        Account objAccount = ((List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST))[0];
        Contact objContact = ((List<Contact>)dataMap.get(KEY_BORROWER_CONTACT_LIST))[0];
        genesis__Applications__c currAppObj = ((List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST))[0];
        clcommon__Party__c partyObj = ((List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST))[0];
        clcommon__Party_Type__c partyTypeObj =  ((List<clcommon__Party_Type__c>)dataMap.get(KEY_PARTY_TYPE_LIST))[0];
        partyTypeObj.Name=PortalConstants.SPOUSE_PARTY_NAME;
        Database.update(partyTypeObj,true);                                
        response.put(KEY_BUSINESS_INFO_FIELD,businessInfoObj);
        response.put(KEY_CONTACT_FIELD,objContact.Id);
        response.put(KEY_CONTACT_LASTNAME_FIELD,objContact.LastName);
        response.put(KEY_PARTY_FIELD,partyObj);
        response.put(KEY_PARTY_ID_FIELD,partyObj.Id);
        response.put(KEY_ACCOUNT_FIELD,objAccount.Id);
        response.put(KEY_ACCOUNT_NAME_FIELD,objAccount.Name);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveAdditionalInfoDetails(response,currAppObj.Id, PortalConstants.SPOUSE_PARTY_NAME);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                List<clcommon__Party__c> partyList = [SELECT Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c, clcommon__Party_Types__c FROM clcommon__Party__c WHERE genesis__Application__c = :currAppObj.Id AND clcommon__Party_Types__c =: PortalConstants.SPOUSE_PARTY_NAME LIMIT 1];
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList.size()>0, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.SPOUSE_PARTY_NAME, partyList[0].clcommon__Party_Types__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(currAppObj.Id, partyList[0].genesis__Application__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Account__c != null, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, partyList[0].clcommon__Contact__c != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test Rate card Details
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testRateCardDetails(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> mapOfRateCards = new Map<String, Object>();                             
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = ((List<genesis__Rate_Card_Setup_Detail__c>)dataMap.get(KEY_RATE_CARD_DETAIL_LIST))[0];
        mapOfRateCards.put(KEY_ID,rateCardDetailObj.Id);
        DateTime startDateTime = DateTime.newInstance(rateCardDetailObj.Start_Date__c, Time.newInstance(PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE));
        DateTime endDateTime = DateTime.newInstance(rateCardDetailObj.End_Date__c, Time.newInstance(PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE));
        mapOfRateCards.put(PortalConstants.FIELD_STARTDATE,startDateTime.format(KEY_DATE_FORMAT));
        mapOfRateCards.put(PortalConstants.FIELD_ENDDATE,endDateTime.format(KEY_DATE_FORMAT));

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getRateCardDetails(mapOfRateCards, RATE_CARD_DESCRIPTION);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }

    /**
    * @description - Test Rate card Details for new rate card
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testRateCardDetailsForNew(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Map<String, Object> mapOfRateCards = new Map<String, Object>();                             
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = ((List<genesis__Rate_Card_Setup_Detail__c>)dataMap.get(KEY_RATE_CARD_DETAIL_LIST))[0];
        mapOfRateCards.put(KEY_ID, null);
        DateTime startDateTime = DateTime.newInstance(rateCardDetailObj.Start_Date__c, Time.newInstance(PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE));
        DateTime endDateTime = DateTime.newInstance(rateCardDetailObj.End_Date__c, Time.newInstance(PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE, PortalConstants.ZERO_VALUE));
        mapOfRateCards.put(PortalConstants.FIELD_STARTDATE,startDateTime.format(KEY_DATE_FORMAT));
        mapOfRateCards.put(PortalConstants.FIELD_ENDDATE,endDateTime.format(KEY_DATE_FORMAT));

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getRateCardDetails(mapOfRateCards, RATE_CARD_DESCRIPTION);
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description - Test Collateral Price
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testGetMapOfCollateralPrices(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<clcommon__Collateral_Category__c> listOfCollateral = new List<clcommon__Collateral_Category__c>();
        clcommon__Collateral_Category__c collateralCategory = ((List<clcommon__Collateral_Category__c>)dataMap.get(KEY_COLLATERAL_CATEGORY_LIST))[0];
        listOfCollateral.add(collateralCategory);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getMapOfCollateralPrices(listOfCollateral);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }
    
    /**
    * @description - Test Collateral Price for Empty collateral
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testGetMapOfCollateralPriceEmpty(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<clcommon__Collateral_Category__c> listOfCollateral = new List<clcommon__Collateral_Category__c>();
        clcommon__Collateral_Category__c collateralCategory = new clcommon__Collateral_Category__c();
        listOfCollateral.add(collateralCategory);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getMapOfCollateralPrices(listOfCollateral);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }

    }

    /**
    * @description - check Email Template
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testGetEmailTemplateList(){
        
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getEmailTemplateList(EMAIL_TEMPLATE_TO_GROWER);
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
        
    }
    
    /**
    * @description - check Email Template for null template name
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testGetEmailTemplateListNull(){
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                List<EmailTemplate> resultList = PortalHelper.getEmailTemplateList(null);
                System.assertEquals(PortalConstants.ZERO_VALUE, resultList.size(), PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
        
    }

    /**
    * @description - get html body for my program approval
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testGetHtmlForMyProgramApproval(){

        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Rate_Card_Setup_Header__c objMyProgram = ((List<genesis__Rate_Card_Setup_Header__c>)dataMap.get(KEY_RATE_CARD_HEADER_LIST))[0];

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
            String returnHtmlString = PortalConstants.EMPTY_STRING;
                try{
                    returnHtmlString = PortalHelper.getHtmlForMyProgramApproval(objMyProgram.Account__r.Name,'www.salesforce.com',objMyProgram.Name);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, !String.isBlank(returnHtmlString),PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
        
    }

    /**
    * @description - get html body for my program approval for null values of acount name, url, my program
    * @author Sk Minsar | 03-12-2025  
    **/
    @isTest
    public static void testGetHtmlForMyProgramApprovalNull(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
            String returnHtmlString = PortalConstants.EMPTY_STRING;
                try{
                    PortalHelper.getHtmlForMyProgramApproval(null, null, null);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(PortalConstants.TRUE_VALUE, String.isBlank(returnHtmlString),PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
        
    }

    /**
    * @description - get html body for my program approval for empty values of acount name, url, my program
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testGetHtmlForMyProgramApprovalEmpty(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
            String returnHtmlString = PortalConstants.EMPTY_STRING;
                try{
                    PortalHelper.getHtmlForMyProgramApproval(PortalConstants.EMPTY_STRING, PortalConstants.EMPTY_STRING, PortalConstants.EMPTY_STRING);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, String.isBlank(returnHtmlString),PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
        
    }

    /**
    * @description - validate Working day
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testIsTodayAWorkingDay(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF));
                } catch (Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
            
    }
    
    /**
    * @description - validate next Working day
    * @author Simran | 08-23-2024 
    **/
    @isTest
    public static void testGetNextWorkingDay(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
            
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.getNextWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF));
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description - Test saveExceptionLog
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testSaveExceptionLog(){

        CustomException objException = new CustomException(KEY_CUSTOM_EXCEPTION_TEXT);
        String exceptionName = KEY_CUSTOM_EXCEPTION;
            
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalHelper.saveExceptionLog(objException, exceptionName);
                List<clcommon__Log__c> insertedLogList = getLogsByName(exceptionName);
                System.assertEquals(PortalConstants.TRUE_VALUE, insertedLogList.size() > PortalConstants.ZERO_VALUE, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(exceptionName, insertedLogList[0].Name, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test saveExceptionLog for null exception
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testSaveExceptionLogNull(){

        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String exceptionName = KEY_CUSTOM_EXCEPTION;
            
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalHelper.saveExceptionLog(null, exceptionName);
                } catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test saveExceptionLog for null exception name
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testSaveExceptionLogNullName(){

        CustomException objException = new CustomException(KEY_CUSTOM_EXCEPTION_TEXT);
        String exceptionName = null;
            
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalHelper.saveExceptionLog(objException, exceptionName);
                List<clcommon__Log__c> insertedLogList = getLogsByName(exceptionName);
                System.assertEquals(PortalConstants.FALSE_VALUE, insertedLogList.size() > PortalConstants.ZERO_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test saveExceptionLog for empty exception name
    * @author Sk Minsar | 03-12-2025 
    **/
    @isTest
    public static void testSaveExceptionLogEmptyName(){

        CustomException objException = new CustomException(KEY_CUSTOM_EXCEPTION_TEXT);
        String exceptionName = PortalConstants.EMPTY_STRING;
            
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalHelper.saveExceptionLog(objException, exceptionName);
                List<clcommon__Log__c> insertedLogList = getLogsByName(exceptionName);
                System.assertEquals(PortalConstants.FALSE_VALUE, insertedLogList.size() > PortalConstants.ZERO_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

}