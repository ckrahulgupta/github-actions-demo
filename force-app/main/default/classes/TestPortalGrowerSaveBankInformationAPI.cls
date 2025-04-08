/**
 * @description       : Test class for PortalGrowerSaveBankInformationAPI
 * @author            : Rahul Gupta | 19-07-2022
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Shristy Kumari
**/
@IsTest
private class TestPortalGrowerSaveBankInformationAPI{
    /**
    * @description make test data for testing
    * @author Soumik Pattanayak | 08-10-2024 
    **/
    @TestSetup
    private static void makeData(){
        // creating legal entity
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        // creating business information for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c gmkBorrBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForGrowmarkBorrower();
        Database.insert(new List<genesis__Business_Information__c>{borrowerBusinessInfoObj, gmkBorrBusinessInfoObj},true);

        // creating Account for borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Account gmkBorrowerAccountObj = ApplicationOriginationTestHelper.createGrowmarkBorrowerAccount(legalEntityObj,gmkBorrBusinessInfoObj.id);
        gmkBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        gmkBorrowerAccountObj.CIF_Number__c = '123455';
        gmkBorrowerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(new List<Account>{borrowerAccountObj, gmkBorrowerAccountObj},true);

        // creating contact for borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Contact gmkBorrowerContactObj = ApplicationOriginationTestHelper.createGrowmarkBorrowerContact(gmkBorrowerAccountObj.id);
        gmkBorrowerContactObj.genesis__SSN__c = '324242425';
        gmkBorrowerContactObj.Confirm_SSN__c = '324242425';
        Database.insert(new List<Contact>{borrowerContactObj, gmkBorrowerContactObj},true);

        // creating user for borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.id);
        User growmarkBorrowerUserObj = ApplicationOriginationTestHelper.createGrowmarkBorrowerUser(gmkBorrowerContactObj.id);
        Database.insert(new List<User>{borrowerUserObj, growmarkBorrowerUserObj},true);
   
        // creating business information for dealer
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // creating account for dealer and certified lender
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(new List<Account>{dealerAccountObj, clAccountObj},true);

        // creating contact for  certified lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        // creating user for certified lender
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(clUserObj,true);
    }
    /**
    * @description : Method to fetch the borrower user
    * @author Soumik Pattanayak | 08-10-2024 
    * @return User 
    **/
    private static User getBorrowerUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Jasmine Albin')];              
        if(objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }
    /**
    * @description : Method to test success scenerio to save bank information for grower
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testGrowerSaveBankInfoSuccess(){
        Map<String, Object> request = new Map<String, Object>(); 
        Map<String, Object> bankDetailsMap = new Map<String, Object>();

        bankDetailsMap.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMap.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMap.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMap.put('clcommon__Bank__c', null);
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__c', null);

        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null) {
            System.runAs(borrowerUserObj){
                Test.startTest();
                PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'The bank information was not saved successfully.');  
                System.assertEquals(1, bankDetailsList.size(), 'Bank account was not created.');
                Test.stopTest();
            }
        }  
    }
    /**
    * @description : Method for testing exception scenerio when bank information is not provided
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testNullBankInfoException(){
        Map<String, Object> request = new Map<String, Object>();
        request.put('bankInformation', null);
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null){
            System.runAs(borrowerUserObj){
                Test.startTest();
                    PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                    clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                    System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception scenerio when bank information is not provided.');
                Test.stopTest();
            }
        }
    }
    /**
    * @description : Method for testing exception when bank information is invalid
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void tesInvalidBankInfoException(){
        Map<String, Object> request = new Map<String, Object>();
        request.put('bankInformation', true);
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null) {
            System.runAs(borrowerUserObj) {
                Test.startTest();
                   PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                   clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                   System.assertEquals(clcommon.Constants.API_EXCEPTION,  response.status ,'Assertion failed for testing exception when bank information is invalid.'); 
                Test.stopTest();
            }
        }  
    }
    /**
    * @description :Method for testing exception scenerio when bank information is empty
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testEmptyBankInfoException(){
        Map<String, Object> request = new Map<String, Object>();
        List<Object> bankDetailsList = new List<Object>();
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null){
            System.runAs(borrowerUserObj){
                Test.startTest();
                    PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                    clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                    System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception scenerio when bank information is empty.'); 
                Test.stopTest();
            }
        }     
    }
    /**
    * @description : Method for testing exception scenerio for saving bank information when Account  Number is null
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testNullAccountNumberException(){
        Map<String, Object> request = new Map<String, Object>();
        Map<String, Object> bankDetailsMap = new Map<String, Object>();
        bankDetailsMap.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMap.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMap.put('clcommon__Bank__c', null);
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__c', null);
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null) {
            System.runAs(borrowerUserObj) {
                Test.startTest();
                    PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                    clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                    System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception scenerio for saving bank information when account number is null.'); 
                Test.stopTest();
            }
        }        
    }
    /**
    * @description :Method for testing exception scenerio for saving bank information when account name is null
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testNullAccountNameException(){
        Map<String, Object> request = new Map<String, Object>();
        Map<String, Object> bankDetailsMap = new Map<String, Object>();
        bankDetailsMap.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMap.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMap.put('clcommon__Bank__c', null);
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__c', null);
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null) {
            System.runAs(borrowerUserObj){
                Test.startTest();
                    PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                    clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                    System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception scenerio for saving bank information when account name is null.'); 
                Test.stopTest();
            }
        }    
    }
    /**
    * @description : Method for testing exception scenerio when for saving bank information routing number is empty
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testNullRoutingNumberException(){
        Map<String, Object> request = new Map<String, Object>();
        Map<String, Object> bankDetailsMap = new Map<String, Object>();
        bankDetailsMap.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMap.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMap.put('clcommon__Bank__c', null);
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__c', null);
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null){
            System.runAs(borrowerUserObj){
                Test.startTest();
                   PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                   clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                   System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception scenerio for saving bank information when routing number is empty.'); 
                Test.stopTest();
            }
        }   
    }
    /**
    * @description : Method for testing exception scenerio when Address in bank detail is empty
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testNullAddressException(){
        Map<String, Object> request = new Map<String, Object>();
        Map<String, Object> bankDetailsMap = new Map<String, Object>();
        bankDetailsMap.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMap.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMap.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null){
            System.runAs(borrowerUserObj){
                Test.startTest();
                   PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                   clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                   System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception scenerio when Address in bank detail is empty.');
                Test.stopTest();
            }
        }
    }
    /**
    * @description : Method to test exception when different bank details have same account number
    * @author Shristy Kumari | 01-03-2025 
    **/
    @IsTest
    private static void testSameAccountNumberException(){
        Map<String, Object> request = new Map<String, Object>();
        Map<String, Object> bankDetailsMapA = new Map<String, Object>();
        bankDetailsMapA.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMapA.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMapA.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMapA.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMapA.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMapA.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMapA.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMapA.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMapA.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMapA.put('clcommon__Bank__c', null);
        bankDetailsMapA.put('clcommon__Bank__r.clcommon__Address__c', null);
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMapA);
        Map<String, Object> bankDetailsMapB = new Map<String, Object>();
        bankDetailsMapB.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMapB.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMapB.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMapB.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMapB.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMapB.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMapB.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMapB.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMapB.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMapB.put('clcommon__Bank__c', null);
        bankDetailsMapB.put('clcommon__Bank__r.clcommon__Address__c', null);
        bankDetailsList.add(bankDetailsMapB);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null){
            System.runAs(borrowerUserObj){
                Test.startTest();
                   PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                   clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                   System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing exception when different bank details have same account number.'); 
                Test.stopTest();
            }
        }       
    }
    /**
    * @description : Method for testing with invalid API method parameter
    * @author Shristy Kumari | 01-03-2025 
    **/
    @IsTest
    private static void testNullParamException(){
        User borrowerUserObj = getBorrowerUser();
        if (borrowerUserObj != null){
            System.runAs(borrowerUserObj){
                Test.startTest();
                   PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                   clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, null);
                   System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion failed for testing with invalid API method parameter.'); 
                Test.stopTest();
            }
        }     
    }
    /**
    * @description : Method to save bank information for grower by Cl user
    * @author Shristy Kumari | 01-02-2025 
    **/
    @IsTest
    private static void testGrowerSaveBankInfoByCL(){
        Map<String, Object> request = new Map<String, Object>(); 
        Map<String, Object> bankDetailsMap = new Map<String, Object>();
        bankDetailsMap.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMap.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMap.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMap.put('clcommon__Bank__c', null);
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__c', null);
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User cllUserObj = [SELECT Id,contactId FROM user WHERE username = 'ross.geller@yopmail.com'];
        if (cllUserObj != null){
            System.runAs(cllUserObj){
                Test.startTest();
                PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'The bank information was not saved successfully.'); 
                System.assertEquals(1, bankDetailsList.size(), 'Bank account was not created.');  
                Test.stopTest();
            }
        }    
    }
    /**
    * @description : Method to save bank information by growmark borrower user
    * @author Shristy Kumari | 01-06-2025 
    **/
    @IsTest
    private static void testGrowerSaveBankInfoByGmkBorrowerSuccess(){
        Map<String, Object> request = new Map<String, Object>(); 
        Map<String, Object> bankDetailsMap = new Map<String, Object>();
        bankDetailsMap.put('clcommon__Bank_Account_Number__c', '123456');
        bankDetailsMap.put('clcommon__Bank_Account_Name__c', 'Rahul Gupta');
        bankDetailsMap.put('clcommon__Routing_Number__c', '432145678');
        bankDetailsMap.put('clcommon__Bank_Name__c', 'Citi Bank');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Phone_Number__c', '9012345678');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c', 'M.G Road');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__City__c', 'Kolkata');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c', 'West Bengal');
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c', '98712');
        bankDetailsMap.put('clcommon__Bank__c', null);
        bankDetailsMap.put('clcommon__Bank__r.clcommon__Address__c', null);
        List<Object> bankDetailsList = new List<Object>();
        bankDetailsList.add(bankDetailsMap);
        request.put('bankInformation', JSON.serialize(bankDetailsList));
        User growmarkBorrowerUserObj = [SELECT Id,contactId FROM user WHERE username = 'william.carry@yopmail.com'];
        if (growmarkBorrowerUserObj != null){
            System.runAs(growmarkBorrowerUserObj){
                Test.startTest();
                PortalGrowerSaveBankInformationAPI saveBankInfoAPIObj = new PortalGrowerSaveBankInformationAPI();
                clcommon.Response response = saveBankInfoAPIObj.invokeAction(null, null, request);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'The bank information was not saved successfully.'); 
                System.assertEquals(1, bankDetailsList.size(), 'Bank account was not created.');  
                Test.stopTest();
            }
        }    
    }
}