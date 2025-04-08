/**********************************************************************************************************************
 * @description       : This is IntegrationTestInitHelper class which helps to create the entire Integration 
 *                      framework for any particular Integration in the org for Testing purpose.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : Kabir Pramanik
**********************************************************************************************************************/

@IsTest
public without sharing class IntegrationTestInitHelper{


    /**
    * @description This method helps to create Integration Family for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param family 
    * @return intframework__Integration_Family__c 
    **/
    public static intframework__Integration_Family__c getFamily(String family){
        intframework__Integration_Family__c apiFamily = new intframework__Integration_Family__c();
        apiFamily.Name = family;
        Database.insert(apiFamily, true);
        return apiFamily;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param family 
    * @return intframework__Integration_Family__c 
    **/
    public static intframework__Integration_Family__c getFamilyInst(String family){
        intframework__Integration_Family__c apiFamily = new intframework__Integration_Family__c();
        apiFamily.Name = family;
        return apiFamily;
    }


    /**
    * @description This method helps to create Integration API Type for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param familyId 
    * @param apiTypeName 
    * @return intframework__Integration_API_Type__c 
    **/
    public static intframework__Integration_API_Type__c getIntegrationAPIType(ID familyId , String apiTypeName){
        intframework__Integration_API_Type__c apiType = new intframework__Integration_API_Type__c();
        apiType.Name = apiTypeName;
        apiType.intframework__Integration_Family__c = familyId;
        Database.insert(apiType, true);
        return apiType;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param familyId 
    * @param apiTypeName 
    * @return intframework__Integration_API_Type__c 
    **/
    public static intframework__Integration_API_Type__c getIntegrationAPITypeInst(ID familyId , String apiTypeName){
        return new intframework__Integration_API_Type__c(Name = apiTypeName, intframework__Integration_Family__c = familyId);
    }


    /**
    * @description This method helps to create Integration Provider for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param familyId 
    * @param intProvider 
    * @return intframework__Integration_Provider__c 
    **/
    public static intframework__Integration_Provider__c getIntegrationProvider(ID familyId , String intProvider){
        intframework__Integration_Provider__c provider = new intframework__Integration_Provider__c();
        provider.Name = intProvider;
        provider.intframework__Integration_Family__c = familyId;
        provider.intframework__Active__c = true ;
        Database.insert(provider, true);
        return provider;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param familyId 
    * @param intProvider 
    * @return intframework__Integration_Provider__c 
    **/
    public static intframework__Integration_Provider__c getIntegrationProviderInst(ID familyId , String intProvider){
        return new intframework__Integration_Provider__c(Name = intProvider, intframework__Integration_Family__c = familyId, intframework__Active__c = true);
    }


    /**
    * @description This method helps to create Integration Configuration for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param provider 
    * @param intConfig 
    * @param endPoint 
    * @return intframework__Integration_Configuration__c 
    **/
    public static intframework__Integration_Configuration__c getIntegrationConfiguration(String provider, 
                                                                                            String intConfig, 
                                                                                            String endPoint){
        intframework__Integration_Configuration__c configuration = new intframework__Integration_Configuration__c();
        configuration.Name = intConfig;
        configuration.intframework__Authentication_Named_Credential__c = endPoint;
        configuration.intframework__Integration_Provider__c = provider;
        Database.insert(configuration, true);
        return configuration;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param provider 
    * @param intConfig 
    * @param endPoint 
    * @return intframework__Integration_Configuration__c 
    **/
    public static intframework__Integration_Configuration__c getIntegrationConfigurationInst(String provider, 
                                                                                            String intConfig, 
                                                                                            String endPoint){
        return new intframework__Integration_Configuration__c(
            Name = intConfig, 
            intframework__Authentication_Named_Credential__c = endPoint, 
            intframework__Integration_Provider__c = provider
        );
    }


    /**
    * @description This method helps to create Integration API Configuration for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param familyId 
    * @param apiTypeId 
    * @param providerId 
    * @param configId 
    * @param longRunningOperation 
    * @param adapterName 
    * @param method 
    * @param apiNamedCred 
    * @param endpoint 
    * @param requestMappingJSON 
    * @param contentType 
    * @param priority 
    * @return intframework__Integration_API_Configuration__c 
    **/
    public static intframework__Integration_API_Configuration__c getIntegrationAPIConfiguration(
            Id familyId,
            Id apiTypeId,
            Id providerId,
            Id configId,
            Boolean longRunningOperation,
            String adapterName,
            String method,
            String apiNamedCred,
            String endpoint,
            String requestMappingJSON,
            String contentType,
            Integer priority) {
        intframework__Integration_API_Configuration__c apiConfiguration = new intframework__Integration_API_Configuration__c();
        apiConfiguration.Name = 'test_API_Config';
        apiConfiguration.intframework__Adapter_Class_Name__c = adapterName;
        apiConfiguration.intframework__HTTP_Method__c = method;
        apiConfiguration.intframework__API_Endpoint__c = endpoint;
        apiConfiguration.intframework__Long_Running_Operation__c = longRunningOperation;
        apiConfiguration.intframework__Execution_Priority__c = priority;
        apiConfiguration.intframework__HTTP_Content_Type__c = contentType;
        //Create the request configuration
        apiConfiguration.intframework__Request_Mapping__c = requestMappingJSON;
        apiConfiguration.intframework__Response_Mapping__c = '';
        apiConfiguration.intframework__Integration_Family__c = familyId;
        apiConfiguration.intframework__Integration_API_Type__c = apiTypeId;
        apiConfiguration.intframework__Integration_Provider__c = providerId;
        apiConfiguration.intframework__Integration_Configuration__c = configId;
        Database.insert(apiConfiguration, true);
        return apiConfiguration;
    }

    
    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param paramMap 
    * @return intframework__Integration_API_Configuration__c 
    **/
    public static intframework__Integration_API_Configuration__c getIntegrationAPIConfigurationInst(Map<String, Object> paramMap) {
        intframework__Integration_API_Configuration__c apiConfiguration = new intframework__Integration_API_Configuration__c();
        apiConfiguration.Name = 'test_API_Config';
        apiConfiguration.intframework__Adapter_Class_Name__c = (String)paramMap.get('adapterName');
        apiConfiguration.intframework__HTTP_Method__c = (String)paramMap.get('method');
        apiConfiguration.intframework__API_Endpoint__c = (String)paramMap.get('endpoint');
        apiConfiguration.intframework__Long_Running_Operation__c = Boolean.valueOf(paramMap.get('longRunningOperation'));
        apiConfiguration.intframework__Execution_Priority__c = Integer.valueOf(paramMap.get('priority'));
        apiConfiguration.intframework__HTTP_Content_Type__c = (String)paramMap.get('contentType');
        //Create the request configuration
        apiConfiguration.intframework__Request_Mapping__c = (String)paramMap.get('requestMappingJSON');
        apiConfiguration.intframework__Response_Mapping__c = '';
        apiConfiguration.intframework__Integration_Family__c = (Id)paramMap.get('familyId');
        apiConfiguration.intframework__Integration_API_Type__c = (Id)paramMap.get('apiTypeId');
        apiConfiguration.intframework__Integration_Provider__c = (Id)paramMap.get('providerId');
        apiConfiguration.intframework__Integration_Configuration__c = (Id)paramMap.get('configId');

        return apiConfiguration;
    }

    /**
    * @description This method helps to create Integration API Configuration for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param integrationFrameworkMap 
    * @return intframework__Integration_API_Configuration__c 
    **/
    public static intframework__Integration_API_Configuration__c getIntegrationAPIConfigurationV2(Map<String,String> integrationFrameworkMap) {
        intframework__Integration_API_Configuration__c apiConfiguration = new intframework__Integration_API_Configuration__c();
        apiConfiguration.Name = 'test_API_Config';
        apiConfiguration.intframework__Adapter_Class_Name__c = integrationFrameworkMap.get('adapterName');
        apiConfiguration.intframework__HTTP_Method__c = integrationFrameworkMap.get('method');
        apiConfiguration.intframework__API_Endpoint__c = integrationFrameworkMap.get('endpoint');
        apiConfiguration.intframework__Long_Running_Operation__c = Boolean.valueOf(integrationFrameworkMap.get('longRunningOperation'));
        apiConfiguration.intframework__Execution_Priority__c = Integer.valueOf(integrationFrameworkMap.get('priority'));
        apiConfiguration.intframework__HTTP_Content_Type__c = integrationFrameworkMap.get('contentType');
        //Create the request configuration
        apiConfiguration.intframework__Request_Mapping__c = integrationFrameworkMap.get('requestMappingJSON');
        apiConfiguration.intframework__Response_Mapping__c = '';
        apiConfiguration.intframework__Integration_Family__c = integrationFrameworkMap.get('familyId');
        apiConfiguration.intframework__Integration_API_Type__c = integrationFrameworkMap.get('apiTypeId');
        apiConfiguration.intframework__Integration_Provider__c = integrationFrameworkMap.get('providerId');
        apiConfiguration.intframework__Integration_Configuration__c = integrationFrameworkMap.get('configId');
        Database.insert(apiConfiguration, true);
        return apiConfiguration;
    }


    /**
    * @description This method helps to create Account with CIF no for testing.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param profileId 
    * @return User 
    **/
    public static User createUser(Id profileId) {
        Account objAccount = new Account(
                Name='Test Account', 
                CIF_Number__c = '115282', 
                BillingCity = 'Kolkata', 
                BillingState = 'West Bengal'
            );
        Database.insert(objAccount, true);
        Contact objContact = new Contact(
                LastName = 'Test Contact', 
                Email='test.account@yopmail.com', 
                accountId = objAccount.Id
            );
        Database.insert(objContact, true);
        User objUser = new User(
                    Alias = 'newUser', 
                    Email='cfanewuser@yopmail.com',
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = profileId, 
                    ContactId = objContact.Id,
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName='cfanewuser@yopmail.com',
                    User_Number__c = 11223344
                );
        Database.insert(objUser, true);
        return objUser;
    }

    /**
    * @description Creating Test Data for Field Staff User
    * @author Ayan Bhowmik | 02-22-2024 
    * @param profileId 
    * @param username 
    * @return User 
    **/
    public static User createFieldStaffUser(Id profileId, String username) {
        Account objAccount = new Account(
                Name='Test Account', 
                CIF_Number__c = '115282', 
                BillingCity = 'Kolkata', 
                BillingState = 'West Bengal'
            );
        Database.insert(objAccount, true);
        Contact objContact = new Contact(
                LastName = 'Test Contact', 
                Email=username, 
                accountId = objAccount.Id
            );
        Database.insert(objContact, true);
        User objUser = new User(
                    Alias = 'newUser', 
                    Email=username,
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = profileId, 
                    ContactId = objContact.Id,
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName=username,
                    User_Number__c = 11223344
                );
        Database.insert(objUser, true);
        return objUser;
    }

    /**
    * @description Creating Test Data for Admin User
    * @author Ayan Bhowmik | 02-22-2024 
    * @param userName 
    * @return User 
    **/
    public static User createAdminUser(String userName) {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User objUser = new User(
                    Alias = 'newUser', 
                    Email=userName,
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = adminProfile.Id, 
                    // ContactId = contactId,
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName=userName,
                    User_Number__c = 11223344
                );
        Database.insert(objUser, true);

        return objUser;
    }

    /**
    * @description Creating Test Data for Seed Data for Pricing Detail
    * @author Ayan Bhowmik | 02-22-2024 
    * @param application 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createSeedDataForPricingDetail(genesis__Applications__c application) {
        String specialSubTrancheString = 'Special Term Sub-Tranche (';
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaders = [
                SELECT Id
                FROM genesis__Rate_Card_Setup_Header__c
                WHERE Id = :application.My_Program__c
            ];

        if (rateCardHeaders.size() == 0) {
            throw new CustomException('No my program found for this test application.');
        }

        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails = [
                SELECT Id,
                       genesis__Enabled_Flag__c,
                       Start_Date__c,
                       End_Date__c,
                       genesis__Interest_Rate__c,
                       Participation_Percentage_Dealer_Subsidy__c,
                       Participation_Percentage_Dealer__c,
                       Special_Term_Reference__c
                FROM genesis__Rate_Card_Setup_Detail__c
                WHERE genesis__Rate_Card_Setup_Header__c = :rateCardHeaders[0].Id
            ];

        List<genesis__Application_Pricing_Detail__c> pricings = new List<genesis__Application_Pricing_Detail__c>();
        for (genesis__Rate_Card_Setup_Detail__c rateCardDetail : rateCardDetails) {
            genesis__Application_Pricing_Detail__c pricing = new genesis__Application_Pricing_Detail__c(
                genesis__Application__c=application.Id,
                genesis__Enabled_Flag__c=true,
                genesis__Rate_Card_Setup_Detail__c=rateCardDetail.Id,
                Loan_Number__c = application.genesis__Loan_Number__c + ConstantValues.HYPHEN_STRING +  String.valueOf(rateCardDetail.Special_Term_Reference__c).substringBetween(specialSubTrancheString,')')
            );

            pricings.add(pricing);            
        }
        return pricings;
        
    }


    /**
    * @description Creating Test Data for Integration Setup Data for Book to Core
    * @author Ayan Bhowmik | 02-22-2024 
    **/
    public static void createIntegrationConfigSetupDataForBookToCore() {
        //Inserting Integration Family
        intframework__Integration_Family__c integrationFamily = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c bookToCoreApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            integrationFamily.Id, 'Post Book To Core NLS Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c bookToCoreProvider = IntegrationTestInitHelper.getIntegrationProvider(
            integrationFamily.Id, 'XML Import');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c bookToCoreConfiguration = IntegrationTestInitHelper.getIntegrationConfiguration(
            bookToCoreProvider.Id,'NLS XML Import Integration Configuration','NLS');

        Map<String, String> bookToCoreApiConfigMap = new Map<String, String> {
                    'adapterName' => 'NLSBookToCoreImportAdapter',
                    'method' => 'POST',
                    'endpoint' => '/nls/xml-import',
                    'longRunningOperation' => 'false',
                    'priority' => '1',
                    'contentType' => 'application/json',
                    'requestMappingJSON' => '{"thirdPartySystem":{"name":"test","filters":[{"objectAPI":"genesis__Applications__c","objectAlias":"Application","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"PricingCount","fieldAPI":"Pricing_Count__c"},{"externalField":"StatementCode","fieldAPI":"Statement_Code__c"},{"externalField":"GrowerCIF","fieldAPI":"genesis__Account__r.CIF_Number__c"},{"externalField":"Tier","fieldAPI":"Dealer_Name__r.Tier__c"},{"externalField":"DealerCIF","fieldAPI":"Dealer_Name__r.CIF_Number__c"},{"externalField":"LoanNumber","fieldAPI":"genesis__Loan_Number__c"},{"externalField":"Entity","fieldAPI":"genesis__Account__r.clcommon__Legal_Entity_Type__r.Name"},{"externalField":"SSN","fieldAPI":"genesis__Contact__r.genesis__SSN__c"},{"externalField":"TaxId","fieldAPI":"genesis__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c"},{"externalField":"ShortName","fieldAPI":"genesis__Account__r.Short_Name__c"},{"externalField":"AccountName","fieldAPI":"genesis__Account__r.Name"},{"externalField":"FirstName","fieldAPI":"genesis__Contact__r.FirstName"},{"externalField":"LastName","fieldAPI":"genesis__Contact__r.LastName"},{"externalField":"MaturityDate","fieldAPI":"genesis__Maturity_Date__c"},{"externalField":"CropYear","fieldAPI":"Crop_Year__c"},{"externalField":"Guarantee","fieldAPI":"Guarantee__c"},{"externalField":"Name","fieldAPI":"Name"},{"externalField":"LoanAmount","fieldAPI":"genesis__Loan_Amount__c"},{"externalField":"CreditTotalDrawLimit","fieldAPI":"Credit_Total_Draw_Limit__c"},{"externalField":"SigningMethod","fieldAPI":"Signing_Method__c"},{"externalField":"LoanTemplate","fieldAPI":"Flex_Rate_Pricing__c"},{"externalField":"CreditRating","fieldAPI":"genesis__Credit_Rating__r.Name"}],"whereClause":"Id = :applicationId"},{"objectAPI":"clcommon__Address__c","objectAlias":"DealerAddress","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"DealerAccount","fieldAPI":"clcommon__Account__c"},{"externalField":"DealerCity","fieldAPI":"clcommon__City__c"},{"externalField":"DealerState","fieldAPI":"clcommon__State_Province__c"},{"externalField":"DealerPortfolioManager","fieldAPI":"clcommon__Account__r.PortfolioManager__r.User_Number__c"},{"externalField":"DealerProdAgOfficer","fieldAPI":"clcommon__Account__r.Production_Ag_loan_officer__r.User_Number__c"}],"whereClause":"clcommon__Account__c = :dealerAccount"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailA","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanA order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailB","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanB order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailC","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanC order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailD","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanD order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailE","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanE order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Rate_Card_Setup_Header__c","objectAlias":"MyProgramHeader","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"closingFee","fieldAPI":"Closing_Fee__c"},{"externalField":"DealerParticipation","fieldAPI":"Dealer_Participate_on_Closing_Fee__c"},{"externalField":"LoanNumberAdvanced","fieldAPI":"Loan_Fee_Advanced_On__c"},{"externalField":"Payer","fieldAPI":"Payer_of_Loan_Closing_Fee__c"},{"externalField":"DealerPortion","fieldAPI":"Portion_of_Fee_to_Cover__c"},{"externalField":"EffectiveDate","fieldAPI":"genesis__Start_Date__c"}],"whereClause":"Id = :myProgId"},{"objectAPI":"clcommon__Floating_Rate_Index__c","objectAlias":"FloatingRateIndex","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"AdvantageRateName","fieldAPI":"Base_Rate_Name__c"},{"externalField":"AdvantageRateValue","fieldAPI":"Current_Floating_Rate__c"},{"externalField":"AdvantageRateAdjuster","fieldAPI":"Base_Rate_Adjuster__c"}],"whereClause":"Name != null"},{"objectAPI":"CFA_Partner_Program__c","objectAlias":"PartnerProgram","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"BaseRate","fieldAPI":"Base_Rate__c"},{"externalField":"BaseRateName","fieldAPI":"Base_Rate__r.Base_Rate_Name__c"},{"externalField":"BaseRateValue","fieldAPI":"Base_Rate__r.Current_Floating_Rate__c"},{"externalField":"BaseRateAdjuster","fieldAPI":"Base_Rate__r.Base_Rate_Adjuster__c"}],"whereClause":"Name = :coopType"}],"dynamicDataParameters":[{"externalField":"coopType"}]}}',
                    'familyId' => integrationFamily.Id,
                    'apiTypeId' => bookToCoreApiType.Id,
                    'providerId' => bookToCoreProvider.Id,
                    'configId' => bookToCoreConfiguration.Id
                };

        IntegrationTestInitHelper.getIntegrationAPIConfigurationV2(bookToCoreApiConfigMap);
    }

    /**
    * @description Creating Test Data for Integration Setup Data for Loan Search
    * @author Ayan Bhowmik | 02-22-2024 
    **/
    public static void createIntegrationConfigSetupDataForLoanSearch() {
        intframework__Integration_Family__c integrationFamily = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c getParentLoanIdAPIType = 
                IntegrationTestInitHelper.getIntegrationAPIType(integrationFamily.Id, ConstantValues.INTEGRATION_API_TYPE_GET_LOANID);
        //Inserting Integration Provider
        intframework__Integration_Provider__c getParentLoanIdProvider = 
                IntegrationTestInitHelper.getIntegrationProvider(integrationFamily.Id, 'Search Loans');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getParentLoanIdConfig = 
                IntegrationTestInitHelper.getIntegrationConfiguration(getParentLoanIdProvider.Id, 'NLS Search Loans Integration Configuration','NLS');
 
        Map<String, String> getParentLoanIdApiConfig = new Map<String, String> {
            'adapterName' => 'NLSLoanSearchAdapter',
            'method' => 'POST',
            'endpoint' => '/loans/search',
            'longRunningOperation' => 'false',
            'priority' => '1',
            'contentType' => 'application/json',
            'requestMappingJSON' => '{"thirdPartySystem": {"name": "Test","filters": [],"dynamicDataParameters": [{"externalField": "loanNumber"}]}}',
            'familyId' => integrationFamily.Id,
            'apiTypeId' => getParentLoanIdApiType.Id,
            'providerId' => getParentLoanIdProvider.Id,
            'configId' => getParentLoanIdConfig.Id
        };

        IntegrationTestInitHelper.getIntegrationAPIConfigurationV2(getParentLoanIdApiConfig);
    }
    /**
    * @description The purpose of this method is to create test account.
    * @author Ayan Bhowmik | 02-20-2024 
    * @return Account 
    **/
    public static Account createAccount(){
        return new Account(Name = 'Red Beard', clcommon__Email__c = 'red.beard@yopmail.com');
    }

    /**
    * @description The purpose of this method is to create test contact.
    * @author Ayan Bhowmik | 02-20-2024 
    * @return Contact 
    **/
    public static Contact createContact(){
        return new Contact(FirstName = 'Red', LastName = 'Beard', genesis__SSN__c = '858589253', Email = 'red.beard@yopmail.com');
    }

    
    /**
    * @description :  The purpose of this method is to create test user
    * @author  Pritam Roy | 03-18-2024 
    * @param profileId 
    * @param objContact 
    * @return User 
    **/
    public static User createUser(Id profileId,Contact objContact){
        return new User(Alias = 'newUser', 
                                Email='cfanewuser@yopmail.com',
                                EmailEncodingKey='UTF-8',
                                LastName='Testing', 
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                ProfileId = profileId, 
                                ContactId = objContact.id,
                                TimeZoneSidKey='America/Los_Angeles', 
                                User_Number__c = 11223344);
    }

    
}