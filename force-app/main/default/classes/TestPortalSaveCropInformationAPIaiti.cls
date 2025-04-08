/**
 * @description       : Test class for PortalSaveCropInformationAPI
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Simran
**/
@isTest
public class TestPortalSaveCropInformationAPIaiti {

    @TestSetup
    static void makeData() {
       // create business information
       genesis__Business_Information__c objDealerBusinessInformation = new genesis__Business_Information__c(
                                                                        genesis__Business_Country__c='India',
                                                                        Approved_Loan_Amount__c=5483528.17,
                                                                        Contract_Loan_Limit__c=10000000,
                                                                        Customised_Individual_Limit__c=250000,
                                                                        Customised_Loan_Limit__c=800000,
                                                                        Remaining_Customised_Limit__c=117984
                                                                    );
        insert objDealerBusinessInformation;

        // create dealer account
        Account objDealerAccount = new Account(
                            Name='Test Dealer',
                            CIF_Number__c = '115282', 
                            BillingCity = 'Kolkata', 
                            BillingState = 'West Bengal',
                            genesis__Business_Information__c = objDealerBusinessInformation.Id
                        );

        insert objDealerAccount;
                    
        // creating user for certified lender
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Certified Lender'];
        User clUser = IntegrationTestInitHelper.createUser(profile.Id);
        Contact clUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :clUser.ContactId];
        Account clUserAccount = [SELECT Id, Name FROM Account WHERE Id = :clUserContact.AccountId];

        clUserAccount.Name = 'Ross Geller';
        clUserAccount.ParentId = objDealerAccount.Id;
        clUserContact.FirstName = 'Ross';
        clUserContact.LastName = 'Geller';

        update clUserAccount;
        update clUserContact;

        clcommon__Reciprocal_Role__c role = new clcommon__Reciprocal_Role__c(Name='Certified Lender');
        Database.insert(role, false);
        clcommon__Relationship__c relationship = 
                        new clcommon__Relationship__c(clcommon__Entity__c=objDealerAccount.Id,
                                                    clcommon__Related_Entity__c=clUserAccount.Id,
                                                    clcommon__Relationship__c=role.Id);
        Database.insert(relationship, false);


        // create legal entity
        clcommon__Legal_Entity__c objEntity= new clcommon__Legal_Entity__c();
        objEntity.Name = 'Individual(s) - Sole Proprietorship';
        objEntity.clcommon__Legal_Entity_Type__c = 'Individual';

        insert objEntity;

        // create borrower
        Account objBorrowerAccount = new Account(name='Rahul Gupta');
        objBorrowerAccount.clcommon__Legal_Entity_Type__c = objEntity.Id;
        insert objBorrowerAccount;
        
        Contact objBorrowerContact = new Contact(FirstName='Rahul', LastName='Gupta');
        objBorrowerContact.AccountId = objBorrowerAccount.Id;

        insert objBorrowerContact;

        // create loan product
        clcommon__CL_Product__c objClProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Simpli-Fi');
        insert objClProduct;

        // create application
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.genesis__CL_Product__c = objClProduct.Id;
        objApplication.genesis__Product_Type__c ='Loan';
        objApplication.genesis__Term__c = 12;
        objApplication.genesis__Interest_Rate__c = 1;
        objApplication.genesis__Loan_Amount__c = 35000;
        objApplication.Crop_Year__c = '2022';
        objApplication.Peak_Loan_Volume__c = 15000;
        objApplication.genesis__Maturity_Date__c = Date.today().addYears(1);
        objApplication.Loan_Id__c = '13900';
        objApplication.genesis__Loan_Number__c = '3HH98762543';
        objApplication.genesis__Account__c = objBorrowerAccount.Id;
        objApplication.genesis__Contact__c = objBorrowerContact.Id;
        objApplication.Certified_Lender__c = clUserAccount.Id;
        objApplication.Dealer_Name__c = objDealerAccount.Id;
        
        insert objApplication;

        // create borrower party type
        clcommon__Party_Type__c objBorrowerPartyType = new clcommon__Party_Type__c(Name = 'BORROWER');
        insert objBorrowerPartyType;

        // create certified lender party
        clcommon__Party_Type__c objCertifiedLenderPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER');
        insert objCertifiedLenderPartyType;

        // create certified lender party
        clcommon__Party_Type__c objDealerPartyType = new clcommon__Party_Type__c(Name = 'DEALER');
        insert objDealerPartyType;

        // create borrower party
        clcommon__Party__c objBorrowerParty = new clcommon__Party__c();
        objBorrowerParty.clcommon__Account__c = objBorrowerAccount.Id;
        objBorrowerParty.clcommon__Contact__c = objBorrowerContact.Id;
        objBorrowerParty.clcommon__Type__c = objBorrowerPartyType.Id;
        objBorrowerParty.genesis__Application__c = objApplication.Id;
        insert objBorrowerParty;

        // create certified lender party
        clcommon__Party__c objCertifiedLenderParty = new clcommon__Party__c();
        objCertifiedLenderParty.clcommon__Account__c = clUserAccount.Id;
        objCertifiedLenderParty.clcommon__Contact__c = clUserContact.Id;
        objCertifiedLenderParty.clcommon__Type__c = objCertifiedLenderPartyType.Id;
        objCertifiedLenderParty.genesis__Application__c = objApplication.Id;
        insert objCertifiedLenderParty;

        // create dealer party
        clcommon__Party__c objDealerParty = new clcommon__Party__c();
        objDealerParty.clcommon__Account__c = objDealerAccount.Id;
        objDealerParty.clcommon__Type__c = objDealerPartyType.Id;
        objDealerParty.genesis__Application__c = objApplication.Id;
        insert objDealerParty;

        List<clcommon__Collateral_Category__c> prices = new List<clcommon__Collateral_Category__c>();
        
        prices.add(
            new clcommon__Collateral_Category__c(
                Name='Soybean',
                Collateral_Unit__c='BU',
                Price_Per_Unit_1__c=12.3,
                Price_Per_Unit_2__c=9.84
            )
        );

        prices.add(
            new clcommon__Collateral_Category__c(
                Name='Corn',
                Collateral_Unit__c='BU',
                Price_Per_Unit_1__c=5.25,
                Price_Per_Unit_2__c=4.2
            )
        );

        Database.insert(prices);

        
    }

    // @TestSetup
    // static void createCollateralCategoryData(){
    //     List<clcommon__Collateral_Category__c> prices = new List<clcommon__Collateral_Category__c>();
        
    //     prices.add(
    //         new clcommon__Collateral_Category__c(
    //             Name='Soybean',
    //             Collateral_Unit__c='BU',
    //             Price_Per_Unit_1__c=12.3,
    //             Price_Per_Unit_2__c=9.84
    //         )
    //     );

    //     prices.add(
    //         new clcommon__Collateral_Category__c(
    //             Name='Corn',
    //             Collateral_Unit__c='BU',
    //             Price_Per_Unit_1__c=5.25,
    //             Price_Per_Unit_2__c=4.2
    //         )
    //     );

    //     Database.insert(prices);
    // }

    /**
    * @description Method is used to get the CL user Id
    * @author Simran | 03-08-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
       
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];
                                    
        if (objUserList.size() == 1) {
            return objUserList[0];
        } 
        
        return null;
    }

    // Providing all valid inputs and should validate is true
    @isTest
    public static void testCase1() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // Providing all valid inputs and should validate is true, feedcollateral is checked
    @isTest
    public static void testCase2() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];

        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', 12));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', 12));

        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Checked');
        
       

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // Providing all valid inputs, feed_collaterals is checked and percent_fed missing
    @isTest
    public static void testCase3() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Checked');
        
       

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                 // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

   

    // Not providng application data
    @isTest
    public static void testCase5() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));

        requestMap.put('application', null);
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // Not providng crop details
    @isTest
    public static void testCase6() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', null);
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // FeedCollateral as null
    @isTest
    public static void testCase7() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', null);
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);  
    
                Test.stopTest();
            }
        }
    }

    // Feedcollateral as invalid string
    @isTest
    public static void testCase8() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Hello');
        
        


        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
                Test.stopTest();
            }
        }
    }

    // invalid insurance plan
    @isTest
    public static void testCase9() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP#$^', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // invalid percent coverage level
    @isTest
    public static void testCase10() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%$%^', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
               // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // not providing any data
    @isTest
    public static void testCase11() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
            
                Test.stopTest();
            }
        }
    }

    // missing total acres
    @isTest
    public static void testCase12() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, null, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        
        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 

    
                Test.stopTest();
            }
        }
    }

    // missing producer share percent
    @isTest
    public static void testCase13() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, null, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // missing approved yield
    @isTest
    public static void testCase15() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, null, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // missing insurance plan
    @isTest
    public static void testCase16() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 18, null, '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // missing percent coverage
    @isTest
    public static void testCase17() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 18, 'ARP', null, null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // missing commodity
    @isTest
    public static void testCase18() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral(null, 20, 50, 18, 'ARP', '55%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
       

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                 // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    public static void testCase19() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('calculatePrice', true);
        requestMap.put('feedCollateral', 'Unchecked');
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    public static void testCase20() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('calculatePrice', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
       

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    public static void testCase21() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        // requestMap.put('application', JSON.serialize(application));
        // requestMap.put('cropDetails', JSON.serialize(collaterals));
        // requestMap.put('shouldValidate', true);
        // requestMap.put('calculatePrice', true);
        // requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
            
                Test.stopTest();
            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    public static void testCase22() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
        
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
        
        // requestMap.put('application', JSON.serialize(application));
        // requestMap.put('cropDetails', JSON.serialize(collaterals));
        // requestMap.put('shouldValidate', true);
        // requestMap.put('calculatePrice', true);
        // requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), null);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 
    
                Test.stopTest();
            }
        }
    }

    @isTest
    public static void testCase23() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = [SELECT Id 
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];

        Database.UpsertResult savedApplication = Database.upsert(application);
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));

        Database.UpsertResult[] savedCollaterals = Database.upsert(collaterals);

        List<genesis__Application_Collateral__c> objApplicationCollateralList = new List<genesis__Application_Collateral__c>();

        for (Database.UpsertResult savedCollateral : savedCollaterals) {
            objApplicationCollateralList.add(new genesis__Application_Collateral__c(
                                                        genesis__Collateral__c=savedCollateral.getId(),
                                                        genesis__Application__c=savedApplication.getId()
                                                    ));
        }

        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 25, 50, 15, 'YP', '50%', null));
        // collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 15, 50, 8, 'ARP', '55%', null));

        Database.upsert(objApplicationCollateralList);
        
        requestMap.put('application', JSON.serialize(application));
        requestMap.put('cropDetails', JSON.serialize(collaterals));
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();

                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 

                Test.stopTest();
            }
        }
    }
@isTest
public static void testLoanConfirmationScenario() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    requestMap.put('loanConfirmation', true);
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}

@isTest
public static void testCollateralZeroScenario() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 0,0,0, 'RP', '50%', null));
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    requestMap.put('collateralZero', true);
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}
    
    @isTest
public static void testCollateralNullScenario() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral(null, null,null,null, null, null, null));
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    requestMap.put('collateralZero', true);
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}


@isTest
public static void testReduceLoanToZeroScenario() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(new List<clcommon__collateral__c>()));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}

@isTest
public static void testDifferentInsurancePlans() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'RP', '50%', null));
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 15, 50, 12, 'ARH', '60%', null));
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 25, 50, 10, 'YP', '65%', null));
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    requestMap.put('calculatePrice', true);
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}
    
@isTest
public static void testLoanAmountGreaterThanCollateralPrice() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id,genesis__Loan_Amount__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    application.genesis__Loan_Amount__c = 1000000000; // Set a very high loan amount
    update application;
    
    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'RP', '50%', null));
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    //requestMap.put('loanConfirmation', true);
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}
   
@isTest
public static void testLoanAmountGreaterThanLCTCollateralPrice() {
    Map<String, Object> requestMap = new Map<String, Object>();
    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    genesis__Applications__c application = [SELECT Id,genesis__Loan_Amount__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    application.genesis__Loan_Amount__c = 1000000000; // Set a very high loan amount
    update application;
    
    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'RP', '50%', null));
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    requestMap.put('loanConfirmation', true);
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
            Test.stopTest();
        }
    }
}

   
// Test for missing required parameters
@isTest
public static void testMissingRequiredParameters() {
    Map<String, Object> requestMap = new Map<String, Object>();
    // Intentionally leave out required parameters

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);
            System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, resp.errorMessage);
        }
    }
}

// Test for missing application ID
@isTest
public static void testMissingApplicationId() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = new genesis__Applications__c(); // No Id
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', '[]');
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    if (objCertifiedLenderUser != null) {
        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);
            System.assertEquals(PortalConstants.APPL_ID_FIELD_MISSING, resp.errorMessage);
        }
    }
}

// Test for unauthorized user
@isTest
public static void testUnauthorizedInternalUser() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', '[]');
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User unauthorizedUser = new User(
        Alias = 'standt',
        Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='internaluser@testorg.com' + Datetime.now().getTime()
    );
    insert unauthorizedUser;
    
    Test.startTest();
    System.runAs(unauthorizedUser) {
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);
        System.assertEquals(PortalConstants.USER_NOT_AUTHORISED, resp.errorMessage);
    }
    Test.stopTest();
}

@isTest
public static void testUnauthorizedCommunityUser() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', '[]');
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    // Create an unauthorized community user
    Profile communityProfile = [SELECT Id FROM Profile WHERE Name='Customer Community%' LIMIT 1];
    Account acc = new Account(Name='Test Account');
    insert acc;
    Contact con = new Contact(LastName='TestContact', AccountId=acc.Id);
    insert con;
    User unauthorizedUser = new User(
        Alias = 'standt',
        Email='communityuser@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = communityProfile.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='communityuser@testorg.com' + Datetime.now().getTime(),
        ContactId = con.Id
    );
    insert unauthorizedUser;
    
    System.runAs(unauthorizedUser) {
        Test.startTest();
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);
        System.assertEquals(PortalConstants.USER_NOT_AUTHORISED, resp.errorMessage);
    }
}

// Test for setting price to 0 when conditions are not met
@isTest
public static void testZeroPriceSetupAndLoanConfirmation() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name = 'Corn' LIMIT 1];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, null, null, null, null, null, null)); // Invalid collateral
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null)); // Valid collateral

    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');
    requestMap.put('calculatePrice', true);
    requestMap.put('loanConfirmation', true);

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    System.runAs(objCertifiedLenderUser) {
        Test.startTest();
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
        
        List<clcommon__collateral__c> updatedCollaterals = [SELECT Price__c FROM clcommon__collateral__c WHERE genesis__Application__c = :application.Id ORDER BY Price__c];
        System.assertEquals(2, updatedCollaterals.size(), 'Two collaterals should be created');
        System.assertEquals(0.00, updatedCollaterals[0].Price__c, 'Invalid collateral price should be set to 0');
        System.assert(updatedCollaterals[1].Price__c > 0, 'Valid collateral price should be greater than 0');

        genesis__Applications__c updatedApplication = [SELECT genesis__Loan_Amount__c, genesis__Requested_Loan_Amount__c FROM genesis__Applications__c WHERE Id = :application.Id];
        System.assertEquals(updatedApplication.genesis__Loan_Amount__c, updatedApplication.genesis__Requested_Loan_Amount__c, 'Loan amount and requested amount should be equal');
    }
}

// Test for creating application collateral junction records
@isTest
public static void testApplicationCollateralJunction() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    
    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 30, 60, 20, 'RP', '60%', null));

    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    System.runAs(objCertifiedLenderUser) {
        Test.startTest();
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
        
        List<genesis__Application_Collateral__c> junctionRecords = [SELECT Id, genesis__Collateral__c FROM genesis__Application_Collateral__c WHERE genesis__Application__c = :application.Id];
        System.assertEquals(2, junctionRecords.size(), 'Two junction records should be created');

        Set<Id> collateralIds = new Set<Id>();
        for (genesis__Application_Collateral__c junction : junctionRecords) {
            collateralIds.add(junction.genesis__Collateral__c);
        }

        List<clcommon__collateral__c> createdCollaterals = [SELECT Id FROM clcommon__collateral__c WHERE Id IN :collateralIds];
        System.assertEquals(2, createdCollaterals.size(), 'Two collaterals should be created and linked');
    }
}

@isTest
public static void testApplicationStageUpdate() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = [SELECT Id, Stage__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '3HH98762543' LIMIT 1];
    application.Stage__c = PortalConstants.CROP_INFORMATION;
    update application;

    List<clcommon__Collateral_Category__c> commodityList = [SELECT Id FROM clcommon__Collateral_Category__c WHERE Name = 'Corn' LIMIT 1];
    
    List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();
    collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));

    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', JSON.serialize(collaterals));
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    System.runAs(objCertifiedLenderUser) {
        Test.startTest();
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.SUCCESS, resp.status);
        
        // Query the application to check if the stage was updated
        genesis__Applications__c updatedApplication = [SELECT Stage__c FROM genesis__Applications__c WHERE Id = :application.Id];
        System.assertEquals(PortalConstants.APPLICANT_SIGNATURE, updatedApplication.Stage__c);
    }
}
    @isTest
public static void testBlankApplicationDetails() {
    Map<String, Object> requestMap = new Map<String, Object>();
    requestMap.put('application', '');
    requestMap.put('cropDetails', '[]');
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    System.runAs(objCertifiedLenderUser) {
        Test.startTest();
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);
        System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, resp.errorMessage);
    }
}
@isTest
public static void testBlankApplicationId() {
    Map<String, Object> requestMap = new Map<String, Object>();
    
    genesis__Applications__c application = new genesis__Applications__c();
    
    requestMap.put('application', JSON.serialize(application));
    requestMap.put('cropDetails', '[]');
    requestMap.put('shouldValidate', true);
    requestMap.put('feedCollateral', 'Unchecked');

    User objCertifiedLenderUser = getCertifiedLenderUser();
    
    System.runAs(objCertifiedLenderUser) {
        Test.startTest();
        PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
        clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();

        System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status);
        System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, resp.errorMessage);
    }
}
    
    
    
    
}