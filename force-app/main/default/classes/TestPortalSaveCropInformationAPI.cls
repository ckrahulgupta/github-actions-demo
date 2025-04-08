/**
 * @description       : Test class for PortalSaveCropInformationAPI
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 13-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
private class TestPortalSaveCropInformationAPI {

    @TestSetup
    static void makeData() {
        ApplicationOriginationSetupTestHelper.createTestSetup();

        List<clcommon__Collateral_Category__c> prices = new List<clcommon__Collateral_Category__c>();
        
        prices.add(ApplicationOriginationTestHelper.createCollateralCategory('Soybean'));
        prices.add(ApplicationOriginationTestHelper.createCollateralCategory('Corn'));

        Database.insert(prices);

        
    }

    /**
    * @description Method is used to get the CL user Id
    * @author Simran | 03-08-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
       
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE UserName = 'ross.geller@yopmail.com'];
                                    
        if (objUserList.size() == 1) {
            return objUserList[0];
        } 
        
        return null;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];
        if(applicationList.size()>0){
            return applicationList[0];
        }
        return null;
    }

    // Providing all valid inputs and should validate is true
    @isTest
    private static void testCaseSuccess() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assetion failed');
                Test.stopTest();

            }
        }
    }

    // Providing all valid inputs and should validate is true, feedcollateral is checked
    @isTest
    private static void testCaseSuccessFeedCollateral() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();

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
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // Providing all valid inputs, feed_collaterals is checked and percent_fed missing
    @isTest
    private static void testCasePercentFedMissing() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

   

    // Not providng application data
    @isTest
    private static void testCaseNoApplication() {
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // Not providng crop details
    @isTest
    private static void testCaseNoCropDeatails() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // FeedCollateral as null
    @isTest
    private static void testCaseFeedCollateralMissing() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed');  
    
                Test.stopTest();

            }
        }
    }

    // Feedcollateral as invalid string
    @isTest
    private static void testCaseFeedCollateralInvalid() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
                Test.stopTest();

            }
        }
    }

    // invalid insurance plan
    @isTest
    private static void testCaseInvalidInsurancePlan() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // invalid percent coverage level
    @isTest
    private static void testCaseInvalidPercentCoverage() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // not providing any data
    @isTest
    private static void testCaseNoData() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
            
                Test.stopTest();

            }
        }
    }

    // missing total acres
    @isTest
    private static void testCaseMissingTotalAcres() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
                Test.stopTest();

            }
        }
    }

    // missing producer share percent
    @isTest
    private static void testCaseMissingProducerShare() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // missing approved yield
    @isTest
    private static void testCaseMissingApprovedYield() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // missing insurance plan
    @isTest
    private static void testCaseMissingInsurancePlan() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // missing percent coverage
    @isTest
    private static void testCaseMissingPercentageCoverage() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // missing commodity
    @isTest
    private static void testCaseMissingCommodity() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    private static void testCaseSuccessValidInput() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assetion failed');
    
                Test.stopTest();
 
            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    private static void testCaseSuccessValidInputs() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();
        
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
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    private static void testCaseSuccessValidInputParameters() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
            
                Test.stopTest();

            }
        }
    }

    // Providing all valid inputs and should validate is true
    @isTest
    private static void testCaseSuccessValidInputParameter() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalSaveCropInformationAPI saveApi = new PortalSaveCropInformationAPI();
                clcommon.Response resp = saveApi.invokeAction('',new List<String>(), null);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
    
                Test.stopTest();

            }
        }
    }

    @isTest
    private static void testCaseAPIException() {
        Map<String, Object> requestmap = new Map<String, Object>();

        User objCertifiedLenderUser = getCertifiedLenderUser();
        
        // Passing data to Application
        genesis__Applications__c application = getApplication();

        Database.UpsertResult savedApplication = Database.upsert(application);
        
        // Passing data to collaterals
        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [SELECT Id 
                                                              FROM clcommon__Collateral_Category__c WHERE Name IN ('Corn', 'Soybean')];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 20, 50, 15, 'YP', '50%', null));
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[1].Id, 10, 50, 8, 'ARP', '55%', null));

        Database.UpsertResult[] savedCollaterals = Database.upsert(collaterals);

        List<genesis__Application_Collateral__c> appCollateralListObj = new List<genesis__Application_Collateral__c>();

        for (Database.UpsertResult savedCollateral : savedCollaterals) {
            appCollateralListObj.add(new genesis__Application_Collateral__c(
                                                        genesis__Collateral__c=savedCollateral.getId(),
                                                        genesis__Application__c=savedApplication.getId()
                                                    ));
        }

        Database.upsert(appCollateralListObj);
        
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
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assetion failed'); 
                Test.stopTest();
            }
        }
    }

    
}