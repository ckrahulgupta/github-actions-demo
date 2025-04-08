/**
 * @description       : Helper Class for Test Classes Contains Methods to provide all the necessary data
 * @author            : simranjha
 * @last modified on  : 01-02-2025
 * @last modified by  : Ayan Khanra
**/

@isTest
global class TestClassHelper { 

    /**
    * @description Creating Test Data for Business Information
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfo(){        
        genesis__Business_Information__c businessInfo = new genesis__Business_Information__c();
        businessInfo.genesis__Business_Country__c='India';
        businessInfo.Remaining_Customised_Limit__c=200000;
        businessInfo.Contract_Loan_Limit__c=300000;
        businessInfo.Approved_Loan_Amount__c=150000;
        businessInfo.genesis__Tax_Identification_Number__c = '666899905';
        Database.insert(businessInfo,true); 
        return businessInfo;
    } 

    /**
    * @description Creating Test Data for Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfo 
    * @return Account 
    **/
    public static Account createAccount(genesis__Business_Information__c businessInfo ){  
        Account accountObj = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.Name='Individual(s) with DBA';
        clEntity.clcommon__Legal_Entity_Type__c='Individual(s) with DBA';
        accountObj.Name='SJha';
        accountObj.CIF_Number__c='123456';
        accountObj.BillingCity='San Mateo';
        accountObj.Short_Name__c='San';
        accountObj.BillingState='CA';
        accountObj.BillingStreet='Waters Park Drive';
        accountObj.BillingPostalCode='41223';
        Database.insert(clEntity,true);
        accountObj.clcommon__Legal_Entity_Type__c = clEntity.Id;
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        Database.insert(accountObj,true);
        return accountObj;
    }

    /**
    * @description Creating Test Data for Sole Prop Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfo 
    * @return Account 
    **/
    public static Account createSolePropAccount(genesis__Business_Information__c businessInfo ){  
        Account accountObj = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship';
        clEntity.Name='Sole Proprietorship';
        Database.Insert(clEntity,true);
        accountObj.Name = 'SJha';
        accountObj.clcommon__Legal_Entity_Type__c = clEntity.Id;
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        accountObj.BillingStreet = 'Test Street';
        accountObj.BillingCity = 'Test City';
        accountObj.BillingState = 'WA';
        accountObj.BillingPostalCode = '11223';
        accountObj.Billing_County__c = 'Test County';
        Database.insert(accountObj,true);
        return accountObj;
    }

    /**
    * @description Creating Test Data for Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @return Contact 
    **/
    public static Contact createContact(){
        Contact contactObj=new Contact();
        contactObj.FirstName='Simran';
        contactObj.LastName='Jha';
        contactObj.Email='simran1@gmail.com';
        contactObj.Phone='9234567890';
        Database.insert(contactObj,true);
        return contactObj;
    }

    /**
    * @description Creating Test Data for Contact with an Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactWithAccountObject(Account accountObj){
        Contact contactObj=new Contact();
        contactObj.AccountId = accountObj.Id;
        contactObj.genesis__SSN__c = '871234678';
        contactObj.FirstName='Itachi';
        contactObj.LastName='Uchiha';
        contactObj.Email='itachi.uchiha@yopmail.com';
        contactObj.Phone='8736583948';
        return contactObj;
    }


    /**
    * @description Creating Test data for party
    * @author Ayan Bhowmik | 02-21-2024 
    * @param acc 
    * @param con 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createParty(Account acc, Contact con){
        clcommon__Party__c clparty = new clcommon__Party__c();
        clparty.clcommon__Account__c=acc.Id;
        clparty.clcommon__Contact__c=con.Id;
        clcommon__Party_Type__c clPartyType = new clcommon__Party_Type__c();
        clPartyType.Name= 'BORROWER';
        Database.Insert(clPartyType,false);
        clparty.clcommon__Type__c = clPartyType.Id;
        Database.insert(clparty,true);
        return clparty;
    }
    /**
    * @description Creating Test Data for Principal Party
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationObj 
    * @param accountObj 
    * @param contactObj 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createPrincipalParty(genesis__Applications__c applicationObj, Account accountObj, Contact contactObj){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        clcommon__Party_Type__c objPartyTypePrincipal = new clcommon__Party_Type__c(Name = 'PRINCIPAL');
        Database.insert(objPartyTypePrincipal);
        partyObj.clcommon__Type__c = objPartyTypePrincipal.Id;
        partyObj.clcommon__Party_Types__c = 'PRINCIPAL';
        partyObj.genesis__Application__c = applicationObj.Id;
        partyObj.clcommon__Account__c = accountObj.Id;
        partyObj.clcommon__Contact__c = contactObj.Id;
        partyObj.Principal_Number__c = 1;
        Database.insert(partyObj);
        return partyObj;
    }

    /**
    * @description Creating Test Data for PartyType/Product/Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplication(){
        Account objAccount = new Account(Name='Test dealer' ,Coop_Type__c='CFA', CIF_Number__c = '115282', BillingCity = 'aaaa', BillingState = 'bbbb');
        Database.insert(objAccount, true);
        
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.clcommon__Product_Name__c ='SimpliFy';
        Database.Insert(clProduct,true);
        
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        clcommon__CL_Purpose__c  clPurposes = new clcommon__CL_Purpose__c();
        clPurposes.Name='Crop';
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '398762543';
        applicationObj.Dealer_Name__c = objAccount.Id;
        applicationObj.Crop_Year__c = '2024';
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.insert(clPurposes,true);
        applicationObj.genesis__CL_Product__c = clProduct.Id;
        applicationObj.genesis__CL_Purpose__c = clPurposes.Id;
        Database.insert(applicationObj,true);
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param dealerId 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplication(Id dealerId){
        Account objAccount = new Account(Name='Test dealer' ,Coop_Type__c='CFA', CIF_Number__c = '115282', BillingCity = 'aaaa', BillingState = 'bbbb');
        Database.insert(objAccount, true);
        
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.clcommon__Product_Name__c ='SimpliFy';
        Database.Insert(clProduct,true);
        
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        clcommon__CL_Purpose__c  clPurposes = new clcommon__CL_Purpose__c();
        clPurposes.Name='Crop';
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '398762543';
        applicationObj.Dealer_Name__c = dealerId;
        applicationObj.Crop_Year__c = '2024';
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.insert(clPurposes,true);
        applicationObj.genesis__CL_Product__c = clProduct.Id;
        applicationObj.genesis__CL_Purpose__c = clPurposes.Id;
        Database.insert(applicationObj,true);
        return applicationObj;
    }
    // public static genesis__Application_Note__c createApplicationNote(genesis__Applications__c applicationObj){
    //     genesis__Application_Note__c objAppnote=new genesis__Application_Note__c(genesis__Application__c=applicationObj.Id,
    //                                                                             Status__c=ConstantValues.APPLICATION_NOTE_APPROVE_STATUS,
    //                                                                             Updated_Loan_Amount__c =425.00,
    //                                                                             Current_Loan_Amount__c=4575.98,
    //                                                                             Current_Maturity_Date__c=Date.today().addMonths(3),
    //                                                                             Modified_Maturity_Date__c =Date.today().addMonths(6));
    //     Database.insert(objAppnote,true);
    //     return objAppnote;
    // }

    /**
    * @description Creating test data for a My Program of a dealer
    * @author Ayan Bhowmik | 02-22-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createRateCardHeader(Account accountObj){
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Crop_Year__c = '2023';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = System.today();
        rateCardHeaderObj.genesis__Transaction_Date__c = System.today();
        String endDateStr = '03/15/2024';
        rateCardHeaderObj.genesis__End_Date__c = Date.parse(endDateStr);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        Database.insert(rateCardHeaderObj,true);
        return rateCardHeaderObj;
    }

    /**
    * @description  Creating test data for a rate card in a my program
    * @author Subham Nandi | 09-02-2022 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetail(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 2;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        String startDateStr = '08/09/2023';
        Date startDate = Date.parse(startDateStr);
        String endDateStr = '03/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardDetailObj.Start_Date__c = startDate;
        rateCardDetailObj.End_Date__c = endDate;
        rateCardDetailObj.genesis__Interest_Rate__c = 6.5;
        Database.insert(rateCardDetailObj,true);
        return rateCardDetailObj;
    }

    /**
    * @description Creating Test Data for Product
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createProduct(){
        clcommon__CL_Product__c productObj = new clcommon__CL_Product__c();
        productObj.clcommon__Product_Name__c = PortalConstants.SIMPLIFY_TYPE;
        RecordType recordTypeId = [SELECT Id, 
                                            Name, 
                                            SobjectType, 
                                            DeveloperName, 
                                            NamespacePrefix 
                                        FROM RecordType 
                                        WHERE Name = 'Loan' AND 
                                            SobjectType = 'clcommon__CL_Product__c'];
        productObj.RecordTypeId = recordTypeId.Id;
        Database.insert(productObj,true);
        return productObj;
    }

    /**
    * @description Creating Test Data for Additional Factor
    * @author Ayan Bhowmik | 02-21-2024 
    * @param rateCardHeader 
    * @return genesis__Additional_Determining_Factor__c 
    **/
    public static genesis__Additional_Determining_Factor__c createAdditionalFactor(genesis__Rate_Card_Setup_Header__c rateCardHeader){
        genesis__Additional_Determining_Factor__c factor = new genesis__Additional_Determining_Factor__c();
        factor.genesis__Field_Value__c = rateCardHeader.Name;
        factor.Name = PortalConstants.MY_PROGRAM_FACTOR_NAME;
        factor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        factor.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        factor.genesis__Applicable_for_Application__c = true;
        factor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        factor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        factor.genesis__Application_Field_API_Name__c = PortalConstants.MY_PROGRAM_FIELD_API_NAME;
        factor.genesis__Application_Field_Name__c = PortalConstants.MY_PROGRAM_FIELD_NAME;
        factor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        factor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        Database.insert(factor,true);
        return factor;
    }

    /**
    * @description Creating Test Data for Additional Factor of Dealer
    * @author Ayan Bhowmik | 02-21-2024 
    * @param rateCardHeader 
    * @return genesis__Additional_Determining_Factor__c 
    **/
    public static genesis__Additional_Determining_Factor__c createAdditionalFactorDealer(genesis__Rate_Card_Setup_Header__c rateCardHeader){
        genesis__Additional_Determining_Factor__c factor = new genesis__Additional_Determining_Factor__c();
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id = :rateCardHeader.Account__c];
        factor.genesis__Field_Value__c = accountObj.Name;
        factor.Name = PortalConstants.DEALER_PROFILE;
        factor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        factor.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        factor.genesis__Applicable_for_Application__c = true;
        factor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        factor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        factor.genesis__Application_Field_API_Name__c = PortalConstants.MY_PROGRAM_DEALER_FIELD;
        factor.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
        factor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        factor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        Database.insert(factor,true);
        return factor;
    }

    /**
    * @description Creating Test Data for PartyType/Product/Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param internalReferenceCode 
    * @param salesAgent 
    * @param yearsOfBusiness 
    * @param myProgram 
    * @param flexRatePricing 
    * @param acceptApplicableGuaranty 
    * @param recommendApplication 
    * @param secondLook 
    * @return genesis__Applications__c 
    **/
public static genesis__Applications__c createApplicationSubmission(String internalReferenceCode,
                                                                    String salesAgent,
                                                                    String yearsOfBusiness,
                                                                    String myProgram,
                                                                    Boolean flexRatePricing,
                                                                    Boolean acceptApplicableGuaranty,
                                                                    String recommendApplication,
                                                                    Boolean secondLook) {

        genesis__Applications__c application = createApplication();
        application.Internal_Reference_Code__c = internalReferenceCode;
        application.Sales_Agent__c = salesAgent;
        application.Years_Of_Business_With_Applicant__c = yearsOfBusiness;
        application.My_Program__c = myProgram;
        application.Flex_Rate_Pricing__c = flexRatePricing;
        application.Do_You_Accept_Applicable_Guaranty__c = acceptApplicableGuaranty;
        application.Do_You_Recommend_Second_Look__c = secondLook;
        return application;
    }



    /**
    * @description Creating Test data for Collaterals
    * @author Ayan Bhowmik | 02-21-2024 
    * @param collateralCategoryId 
    * @param totalAcres 
    * @param producerSharePercent 
    * @param approvedYield 
    * @param insurancePlan 
    * @param percentCoverageLevel 
    * @param percentFed 
    * @return clcommon__collateral__c 
    **/
    public static clcommon__collateral__c createCollateral(String collateralCategoryId,
                                                        Double totalAcres,
                                                        Double producerSharePercent,
                                                        Double approvedYield,
                                                        String insurancePlan,
                                                        String percentCoverageLevel,
                                                        Double percentFed) {
        // Passing data to Collaterals
        return new clcommon__collateral__c(clcommon__Collateral_Category__c=collateralCategoryId,
                                            clcommon__Collateral_Name__c='commodity',
                                            Total_Acres__c=totalAcres,
                                            Producer_Share_Percent__c=producerSharePercent,
                                            Approved_Yield__c=approvedYield,
                                            Insurance_Plan__c=insurancePlan,
                                            Percent_Coverage_Level__c=percentCoverageLevel,
                                            Percent_Fed__c=percentFed);
    }


    /**
    * @description Creating Test Data for Dealer company account
    * @author Ayan Bhowmik | 02-22-2024 
    * @param businessInfo 
    * @return Account 
    **/
    public static Account createDealerParentAccount(genesis__Business_Information__c businessInfo ){  
        Account accountObj = new Account();
        accountObj.Name='AMKE Enterprise';
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        Database.insert(accountObj,true);
        return accountObj;
    }


    /**
    * @description Creating Test Data for Dealer user account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfo 
    * @param parentAccount 
    * @return Account 
    **/
    public static Account createDealerChildAccount(genesis__Business_Information__c businessInfo, Account parentAccount ){  
        Account accountObj = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.Name='Individual';
        Database.insert(clEntity,true);
        accountObj.Name='Dealer Bob';
        accountObj.ParentId = parentAccount.Id;
        accountObj.clcommon__Legal_Entity_Type__c = clEntity.Id;
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        Database.insert(accountObj,true);
        return accountObj;
    }


    /**
    * @description Creating Test Data for applciation for flex rate
    * @author Ayan Bhowmik | 02-21-2024 
    * @param clProduct 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createAppllicationForFlex(clcommon__CL_Product__c clProduct, Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Term__c = 19;
        applicationObj.genesis__Interest_Rate__c = 1.45;
        applicationObj.genesis__Loan_Amount__c = 7685;
        applicationObj.genesis__CL_Product__c = clProduct.Id;
        Database.insert(applicationObj,true);
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Product Rate Card Association
    * @author Ayan Bhowmik | 02-21-2024 
    * @param product 
    * @param rateCard 
    * @return genesis__Product_Rate_Card_Association__c 
    **/
    public static genesis__Product_Rate_Card_Association__c createRateToProduct(clcommon__CL_Product__c product, genesis__Rate_Card_Setup_Header__c rateCard){
        genesis__Product_Rate_Card_Association__c rateToProduct = new genesis__Product_Rate_Card_Association__c();
        rateToProduct.genesis__CL_Product__c = product.Id;
        rateToProduct.genesis__Rate_Card_Setup__c = rateCard.Id;
        Database.insert(rateToProduct,true);
        return rateToProduct;
    }

    /**
    * @description Creating  Test Data for Bank Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__Bank_Account__c 
    **/
    public static clcommon__Bank_Account__c createBankAccount(){
        clcommon__Bank_Account__c bankInfo = new clcommon__Bank_Account__c();
        bankInfo.clcommon__Bank_Account_Number__c = '5003101002225';
        bankInfo.clcommon__Bank_Account_Name__c = 'Sam Grower';
        bankInfo.clcommon__Routing_Number__c = '123456789';
        Database.insert(bankInfo,true);
        return bankInfo;
    }

    /**
    * @description Creating Test Data for Pricing Details
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    public static genesis__Application_Pricing_Detail__c createPricingDetail(String applicationId){
        genesis__Application_Pricing_Detail__c newPricingDetails = new genesis__Application_Pricing_Detail__c();
        newPricingDetails.genesis__Maximum_Financed_Amount__c = 15000;
        newPricingDetails.genesis__Rate_Factor_Based_On_Amount__c = 100;
        newPricingDetails.genesis__Rate_Factor__c = 0.00;
        newPricingDetails.genesis__Term__c = 12;
        newPricingDetails.genesis__Yield_Percent__c = 0.00;
        newPricingDetails.genesis__Application__c = applicationId;
        newPricingDetails.Loan_Number__c = '123234345-A';
        newPricingDetails.Loan_Id__c = '139001';
        newPricingDetails.Maturity_Date__c = Date.today().addYears(1);
        newPricingDetails.Interest_Per_Diem__c = 100;
        newPricingDetails.Fees__c = 100;
        Database.insert(newPricingDetails,true);
        return newPricingDetails;
    }

    // public static genesis__Application_Fee_Payment__c createApplicationFeePayment(String externalId,String applicationId)
    // {
    //     genesis__Application_Fee_Payment__c newApplicationFeePayment = new genesis__Application_Fee_Payment__c();
    //     newApplicationFeePayment.External_Id__c = externalId;
    //     //newApplicationFeePayment.Pricing_Detail__c = pricingDetail;
    //     newApplicationFeePayment.Interest_Earned__c=10;
    //     newApplicationFeePayment.Interest_Paid__c=10;
    //     newApplicationFeePayment.Dealer_Monthly_Interest__c=10;
    //     newApplicationFeePayment.Past_Due_Balance__c=10;
    //     newApplicationFeePayment.Month__c=12;
    //     newApplicationFeePayment.Year__c=2022;
    //     newApplicationFeePayment.genesis__Application__c = applicationId;
    //     //newApplicationFeePayment.Record_Type__c='PARTICIPANT DAILY';

    //     //Database.insert(newApplicationFeePayment, true);
    //     return newApplicationFeePayment;
    // }

    /**
    * @description Creating Test Data for Application Fee Payment List
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @param pricingDetail 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    public static List<genesis__Application_Fee_Payment__c> createApplicationFeePaymentList (String applicationId, String pricingDetail){
        List<genesis__Application_Fee_Payment__c> objApplicationFeePaymentList = new List<genesis__Application_Fee_Payment__c>();

        objApplicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c='weqasweqwe1124',
                                                    Interest_Earned__c=10,
                                                    Interest_Paid__c=10,
                                                    Dealer_Monthly_Interest__c=10,
                                                    Past_Due_Balance__c=10,
                                                    Month__c=12,
                                                    Year__c=2022,
                                                    Pricing_Detail__c=pricingDetail,
                                                    genesis__Application__c=applicationId,
                                                    Record_Type__c='ACTIVE LOAN DAILY'
                                                ));

        objApplicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c='weqasweqwde1124',
                                                    Interest_Earned__c=10,
                                                    Interest_Paid__c=10,
                                                    Dealer_Monthly_Interest__c=10,
                                                    Past_Due_Balance__c=10,
                                                    Month__c=0,
                                                    Year__c=2022,
                                                    Pricing_Detail__c=pricingDetail,
                                                    genesis__Application__c=applicationId,
                                                    Record_Type__c='ACTIVE LOAN DAILY'
                                                ));
        

        objApplicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c='weqweqwsde1124',
                                                    Interest_Earned__c=10,
                                                    Interest_Paid__c=10,
                                                    Dealer_Monthly_Interest__c=10,
                                                    Past_Due_Balance__c=10,
                                                    Month__c=12,
                                                    Year__c=2022,
                                                    Pricing_Detail__c=pricingDetail,
                                                    genesis__Application__c=applicationId,
                                                    Record_Type__c='PARTICIPANT DAILY'
                                                ));
        
        objApplicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c='weqwqeqwsde1124',
                                                    Interest_Earned__c=10,
                                                    Interest_Paid__c=10,
                                                    Dealer_Monthly_Interest__c=10,
                                                    Past_Due_Balance__c=10,
                                                    Month__c=0,
                                                    Year__c=2022,
                                                    Pricing_Detail__c=pricingDetail,
                                                    genesis__Application__c=applicationId,
                                                    Record_Type__c='PARTICIPANT DAILY'
                                                ));
        
        //Database.insert(objApplicationFeePaymentList, true);
        return objApplicationFeePaymentList;

    }

    /**
    * @description Creating Test Data for Funding Transaction
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paymentMode 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createFundingTransaction(String paymentMode){
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c(Name=paymentMode);
        Database.insert(objPaymentMode, false);
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Payment_Mode__c = objPaymentMode.Id;
        objFundingTransaction.genesis__Funding_Date__c = date.today();
        objFundingTransaction.genesis__Amount__c = 1500;
        objFundingTransaction.genesis__Reference__c = 'Crop';
        Database.insert(objFundingTransaction, true);
        return objFundingTransaction;
    }

    /**
    * @description Creating Test data for Content Document
    * @author Ayan Bhowmik | 02-21-2024 
    * @return ContentDocument 
    **/
    public static ContentDocument createContentDocument() {
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];


        return contentDocuments[0];
    }


    /**
    * @description Creating Test data for Content Document Link
    * @author Ayan Bhowmik | 02-21-2024 
    * @param application 
    * @param contentDocument 
    **/
    public static void createContentDocumentLink(genesis__Applications__c application, ContentDocument contentDocument) {
        

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = application.Id;
        contentDocumentLink.ContentDocumentId = contentDocument.Id;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        
        // insert contentDocumentLink;
        Database.insert(contentDocumentLink,true);
    }

    /**
    * @description Creating Test data for Content Version
    * @author Ayan Bhowmik | 02-21-2024 
    **/
    public static void createContentVersion() {
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = PortalConstants.AGREEMENT_FILE_NAME,
            PathOnClient   = PortalConstants.AGREEMENT_FILE_NAME,
            VersionData    = Blob.valueOf('Test Credit Application Agreement Content'),
            IsMajorVersion = true);
        
        Database.insert(contentVersion,true);

        // return contentVersion;
    }


    /**
    * @description Creating Test data for Content Version
    * @author Ayan Bhowmik | 02-21-2024 
    * @param fileName 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(String fileName) {
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = fileName,
            PathOnClient   = fileName,
            VersionData    = Blob.valueOf('Test Credit Application Agreement Content'),
            IsMajorVersion = true);
        
        Database.insert(contentVersion,true);

        return contentVersion;
    }

    /**
    * @description Creating Test Data for User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param profileId 
    * @param userName 
    * @return User 
    **/
    public static User createUser(Id profileId, String userName){
        Account objAccount = new Account(Name='TestAccount' , CIF_Number__c = '091284', BillingCity = 'cccc', BillingState = 'dddd');
        Database.insert(objAccount, true);
        Contact objContact = new Contact(LastName = 'Test Contact',Email='test.account@yopmail.com', accountId = objAccount.Id);
        Database.insert(objContact, true);
        User objUser = new User(Alias = 'newUser', Email='cfanewus5er@yopmail.com',EmailEncodingKey='UTF-8',
                                        LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                        ProfileId = profileId, ContactId = objContact.Id,
                                        TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        Database.insert(objUser, true);
        return objUser;
    }


    /**
    * @description Creating Test Data for Relationship between CL and Dealer
    * @author Ayan Bhowmik | 02-21-2024 
    * @param roleName 
    * @return clcommon__Relationship__c 
    **/
    public static clcommon__Relationship__c createRelationship(String roleName) {
        clcommon__Reciprocal_Role__c objRole = new clcommon__Reciprocal_Role__c(Name=roleName);
        Database.insert(objRole, true);
        clcommon__Relationship__c objRelationship = new clcommon__Relationship__c();
        objRelationship.clcommon__Relationship__c = objRole.Id;
        Database.insert(objRelationship, true);
        return objRelationship;
    }
    /**
    * @description Creating Test Data for Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccount(Id businessInfoId){
        Account objAccount = new Account(Name = 'Alfred Hitchcock');
        objAccount.genesis__Business_Information__c = businessInfoId;
        objAccount.Phone = '666714588';
        objAccount.BillingStreet = '2423 6th Avenue';
        objAccount.BillingCity = 'Frankenmouth';
        objAccount.BillingState = 'Michigan';
        objAccount.BillingPostalCode = '61232';
        Database.insert(objAccount, true);
        return objAccount;
    }

/***********************************************************************************************************/
/* Version 2 of all methods start from here. */ 
/***********************************************************************************************************/


    /**
    * @description Creating Test Data for Dealer Business Information 
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForDealer(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=200000;
        businessInfoObj.Contract_Loan_Limit__c=300000;
        businessInfoObj.Approved_Loan_Amount__c=150000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '666899905';
        return businessInfoObj;
    }


    /**
    * @description Creating Test Data for Borrower Business Information
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForBorrower(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=100000;
        businessInfoObj.Contract_Loan_Limit__c=500000;
        businessInfoObj.Approved_Loan_Amount__c=200000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '122334556';
        return businessInfoObj;
    }
    /**
    * @description Creating Test Data for CIF Number
    * @author Ayan Bhowmik | 02-21-2024 
    * @return CFA_Configuration__c 
    **/
    public static CFA_Configuration__c createCIFNumber(){
        CFA_Configuration__c cifObj = new CFA_Configuration__c();
        cifObj.CIF_Number__c='32454345';
        return cifObj;
    }
// DEALER RELATED METHODS START :-----------------------------------------------------------


    /**
    * @description Creating Test Data for Dealer Account With Coop Type CFA
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createDealerAccount(Id businessInfoId) {
        Account dealerAccountObj = new Account();
        dealerAccountObj.Name = 'Kisan Loan';
        dealerAccountObj.genesis__Business_Information__c = businessInfoId;
        dealerAccountObj.Phone = '1234567890';
        dealerAccountObj.BillingStreet = '2423 6th Avenue';
        dealerAccountObj.BillingCity = 'Frankenmouth';
        dealerAccountObj.BillingState = 'Michigan';
        dealerAccountObj.BillingPostalCode = '61232';
        dealerAccountObj.CIF_Number__c = '091284';
        dealerAccountObj.Coop_Type__c = 'CFA';
        dealerAccountObj.Tier__c = 'Gold';
        // dealerAccountObj.IFP_checkbox__c = false;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        return dealerAccountObj;
    }


    /**
    * @description Creating Test Data for Dealer Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createDealerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Kisan';
        contactObj.LastName='Loan';
        contactObj.Email='kisan.loan@yopmail.com';
        contactObj.Phone='1234567890';
        contactObj.accountId = objAccountId;
        return contactObj;
    }

    // Creating Dealer Account With Coop Type GMK

    /**
    * @description 
    * @author Simran | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createGMKDealerAccount(Id businessInfoId) {
        Account dealerAccountObj = new Account();
        dealerAccountObj.Name = 'Kisan Lessy';
        dealerAccountObj.genesis__Business_Information__c = businessInfoId;
        dealerAccountObj.Phone = '1234567098';
        dealerAccountObj.BillingStreet = '2423 6th Avenue';
        dealerAccountObj.BillingCity = 'Frankenmouth';
        dealerAccountObj.BillingState = 'Michigan';
        dealerAccountObj.BillingPostalCode = '61232';
        dealerAccountObj.CIF_Number__c = '091289';
        dealerAccountObj.Coop_Type__c = 'Growmark';
        dealerAccountObj.Tier__c = 'Gold';
        // dealerAccountObj.IFP_checkbox__c = false;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        return dealerAccountObj;
    }

    // Creating Dealer Contact

    /**
    * @description 
    * @author Simran | 02-21-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createGMKDealerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Kisan';
        contactObj.LastName='Lessy';
        contactObj.Email='kisan.lessy@yopmail.com';
        contactObj.Phone='1234567098';
        contactObj.accountId = objAccountId;
        return contactObj;
    }
// DEALER RELATED METHODS END :-----------------------------------------------------------------------
// Creating Field Staff Account

    /**
    * @description 
    * @author Simran | 02-21-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createFSAgentAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Ross FieldStaff';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '666714590';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'Michigan';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009909';
        clAccountObj.clcommon__Email__c = 'ross.fieldstaff@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Field Staff Agent').getRecordTypeId();
        return clAccountObj;
    }

    // Creating Certified Lender Contact

    /**
    * @description 
    * @author Simran | 02-21-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createFSAgentContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Ross';
        clContactObj.LastName='FieldStaff';
        clContactObj.Email='ross.fieldstaff@yopmail.com';
        clContactObj.Phone='666714590';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    // Creating Certified Lender User

    /**
    * @description 
    * @author Simran | 02-21-2024 
    * @param contactID 
    * @return User 
    **/
    public static User createFSAgentUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Field Staff Agent'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='ross.fieldstaff@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='ross.fieldstaff@yopmail.com';
        return clUserObj;
    }

// CERTIFIED LENDER RELATED METHODS START :------------------------------------------------------------

    /**
    * @description Creating Test Data for Certfied Lender Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createCLAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Ross Geller';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '666714588';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'Michigan';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009988';
        clAccountObj.clcommon__Email__c = 'ross.geller@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Certified Lender').getRecordTypeId();
        return clAccountObj;
    }


    /**
    * @description Creating Test Data for Certified Lender Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createCLContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Ross';
        clContactObj.LastName='Geller';
        clContactObj.Email='ross.geller@yopmail.com';
        clContactObj.Phone='666714588';
        clContactObj.accountId = accountId;
        return clContactObj;
    }


    /**
    * @description Creating Test Data for Certified Lender User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param contactID 
    * @return User 
    **/
    public static User createCLUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Certified Lender'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='cfanewus5er@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='ross.geller@yopmail.com';
        return clUserObj;
    }


    /**
    * @description Creating Test Data for Standard User
    * @author Ayan Bhowmik | 02-21-2024 
    * @return User 
    **/
    public static User createStandardUser(){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Standard User'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser2';
        clUserObj.Email='cfastdus5er@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='standard';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        //clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='std.user@yopmail.com';
        return clUserObj;
    }
// CERTIFIED LENDER RELATED METHODS END  :-----------------------------------------------------------

// SALES AGENT RELATED METHODS START  :--------------------------------------------------------------

    /**
    * @description Creating Test Data for Sales Agent Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createSalesAgentAccount(Id businessInfoId, Id dealerAccountId){
        Account saAccountObj = new Account();
        saAccountObj.Name = 'Tony Stark';
        saAccountObj.genesis__Business_Information__c = businessInfoId;
        saAccountObj.Phone = '98765453456';
        saAccountObj.BillingStreet = '2423 6th Avenue';
        saAccountObj.BillingCity = 'Frankenmouth';
        saAccountObj.BillingState = 'Michigan';
        saAccountObj.BillingPostalCode = '61232';
        saAccountObj.CIF_Number__c = '787867';
        saAccountObj.clcommon__Email__c = 'tony.stark@yopmail.com';
        saAccountObj.ParentId = dealerAccountId;
        saAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent').getRecordTypeId();
        return saAccountObj;
    } 


    /**
    * @description Creating Test Data for Sales Agent Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createSalesAgentContact(Id accountId){
        Contact saContactObj=new Contact();
        saContactObj.FirstName='Tony';
        saContactObj.LastName='Stark';
        saContactObj.Email='tony.Stark@yopmail.com';
        saContactObj.Phone='98765453456';
        saContactObj.accountId = accountId;
        return saContactObj;
    }


    /**
    * @description Creating Test Data for Sales Agent User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param saContactId 
    * @return User 
    **/
    public static User createSalesAgentUser(Id saContactId){
        Profile saProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Sales Agent'
                                    LIMIT 1];
        User saUserObj = new User();
        saUserObj.Alias = 'newUser';
        saUserObj.Email='cfanewus5er@yopmail.com';
        saUserObj.EmailEncodingKey='UTF-8';
        saUserObj.LastName='Testing';
        saUserObj.LanguageLocaleKey='en_US';
        saUserObj.LocaleSidKey='en_US';
        saUserObj.ProfileId = saProfileObj.Id;
        saUserObj.ContactId = saContactId;
        saUserObj.TimeZoneSidKey='America/Los_Angeles';
        saUserObj.UserName='tony.stark@yopmail.com';
        return saUserObj;
    }

// SALES AGENT RELATED METHODS END  :-----------------------------------------------------------

// CREATING RECIPROCAL ROLE FOR ALL ROLE TYPE START  :------------------------------------------

    /**
    * @description Creating Test Data for Reciprocal Role
    * @author Ayan Bhowmik | 02-21-2024 
    * @param name 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createReciprocalRole(String name) {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = name;
        return roleObj;    
    }
// CREATING RECIPROCAL ROLE FOR ALL ROLE TYPE END :---------------------------------------------

// ESTABLISH RELATIONSHIP BETWEEN CL AND DEALER METHODS START :---------------------------------
    // Creating Relationship Between Dealer and CL
    // Use createReciprocalRoleV2 Mehtod to Create Reciprocal Role

    /**
    * @description Creating Test Data for Relationship Between CL and Dealer
    * @author Ayan Bhowmik | 02-21-2024 
    * @param clRoleObj 
    * @param dealerAccountId 
    * @param clAccountId 
    * @return clcommon__Relationship__c 
    **/
    public static clcommon__Relationship__c createCLDealerRelationship(clcommon__Reciprocal_Role__c clRoleObj,
                                                                        Id dealerAccountId,
                                                                        Id clAccountId) {
        clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
        relationshipObj.clcommon__Relationship__c = clRoleObj.Id;
        relationshipObj.clcommon__Entity__c = dealerAccountId;
        relationshipObj.clcommon__Related_Entity__c = clAccountId;
        return relationshipObj;
    }
    
// ESTABLISH RELATIONSHIP BETWEEN CL AND DEALER METHODS END :-----------------------------------

// GROWER RELATED METHODS START  :--------------------------------------------------------------

    /**
    * @description Creating Test Data for Legal Entity
    * @author Ayan Bhowmik | 02-21-2024 
    * @param name 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createLegalEntity(String name) {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = name;
        entityObj.Name = name;
        return entityObj;
    }


    /**
    * @description Creating Test Data for Sole Prop Borrower Account
    * @author Ayan Bhowmik | 02-22-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createSolePropAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Jasmine Albin';
        accountObj.clcommon__Email__c='jasmin.albin@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingStreet = 'Test Street';
        accountObj.BillingCity = 'Test City';
        accountObj.BillingState = 'WA';
        accountObj.BillingPostalCode = '11223';
        accountObj.Billing_County__c = 'Test County';
        return accountObj;
    }


    /**
    * @description Creating Test Data for Cooporation Borrower Account
    * @author Ayan Bhowmik | 02-22-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createCooporationAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Test Co';
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        borrowerAccountObj.genesis__Business_Information__c=businessInfoId;
        borrowerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return borrowerAccountObj;
    }

    /**
    * @description Creating Test Data for Borrower Contact
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createBorrowerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Jasmine';
        contactObj.LastName='Albin';
        contactObj.Email='jasmin.albin@yopmail.com';
        contactObj.Phone='9734227544';
        contactObj.MobilePhone = '342134234';
        contactObj.accountId = objAccountId;
        contactObj.MailingStreet = 'Test Street';
        contactObj.MailingCity = 'Test City';
        contactObj.MailingState = 'WA';
        contactObj.MailingPostalCode = '11223';
        contactObj.Mailing_County__c = 'Test County';
        contactObj.Birthdate = Date.valueOf('1995-01-01');
        contactObj.genesis__SSN__c = '112233445';
        contactObj.Confirm_SSN__c = '112233445';
        return contactObj;
    }


    /**
    * @description  Creating Test Data for Borrower Contact
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createBorrowerContactV2(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Rose';
        contactObj.LastName='Flower';
        contactObj.Email='jasmin.albin@yopmail123.com';
        contactObj.Phone='9732333344';
        contactObj.MobilePhone = '3421342342';
        contactObj.genesis__SSN__c = '332211559';
        contactObj.accountId = objAccountId;
        return contactObj;
    }

    /**
    * @description Creating Test Data for Borrower Profile 
    * @author Ayan Bhowmik | 02-22-2024 
    * @return Profile 
    **/
    public static Profile getBorrowerProfile() {
        Profile borrowerProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Grower'
                                    LIMIT 1];
        return borrowerProfileObj;
    }


    /**
    * @description Creating Test Data for Borrower User
    * @author Ayan Bhowmik | 02-22-2024 
    * @param borrowerContactId 
    * @return User 
    **/
    public static User createBorrowerUser(Id borrowerContactId){
        Profile borrowerProfileObj = getBorrowerProfile();
        User borrowerUserObj = new User();
        borrowerUserObj.Alias = 'newUser';
        borrowerUserObj.Email='cfanewus5er@yopmail.com';
        borrowerUserObj.EmailEncodingKey='UTF-8';
        borrowerUserObj.LastName='Testing';
        borrowerUserObj.LanguageLocaleKey='en_US';
        borrowerUserObj.LocaleSidKey='en_US';
        borrowerUserObj.ProfileId = borrowerProfileObj.Id;
        borrowerUserObj.ContactId = borrowerContactId;
        borrowerUserObj.TimeZoneSidKey='America/Los_Angeles';
        borrowerUserObj.UserName='jasmine.albin@yopmail.com';
        return borrowerUserObj;
    }

// GROWER RELATED METHODS END  :-----------------------------------------------------------------

// APPLICATION RELATED METHODS START  :-----------------------------------------------------------

    /**
    * @description Creating Test Data for CL Product of Application
    * @author Ayan Bhowmik | 02-22-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLProductForApplication() {
        clcommon__CL_Product__c clProductObj = new clcommon__CL_Product__c();
        clProductObj.clcommon__Product_Name__c ='Simpli-Fi';
        return clProductObj;
    }


    /**
    * @description Creating Test data for Purpose of Application
    * @author Ayan Bhowmik | 02-22-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurposeForApplication() {
        clcommon__CL_Purpose__c  clPurposeObj = new clcommon__CL_Purpose__c();
        clPurposeObj.Name='Crop';
        return clPurposeObj;
    }


    /**
    * @description Creating data for Purpose of Application
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createCurrCropYearApplication(Map<String, Id> paramMap){
        Integer month = System.today().month();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '300023456';
        applicationObj.genesis__Status__c = 'ACTIVE';
        applicationObj.Reserved_Amount__c = 15000;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = true;
        if(month >= 6){
            applicationObj.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        }
        applicationObj.Dealer_Name__c = paramMap.get('dealerAccountId');
        applicationObj.genesis__CL_Product__c = paramMap.get('clProductId');
        applicationObj.genesis__CL_Purpose__c = paramMap.get('clPurposeId');
        applicationObj.genesis__Account__c = paramMap.get('borrowerAccountId');
        applicationObj.genesis__Contact__c = paramMap.get('borrowerContactId');
        applicationObj.Certified_Lender__c = paramMap.get('clAccountId');
        applicationObj.Signing_Method__c = 'Email - Docusign';
        return applicationObj;
    }   


    /**
    * @description Creating an Application Which is ACTIVATED for Current Crop Year 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createNewlyCreatedApplication(Map<String, Id> paramMap){
        Integer month = System.today().month();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '300023456';
        applicationObj.genesis__Status__c = 'NEW - ENTERED';
        applicationObj.Reserved_Amount__c = 15000;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = true;
        if(month >= 6){
            applicationObj.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        }
        applicationObj.Dealer_Name__c = paramMap.get('dealerAccountId');
        applicationObj.genesis__CL_Product__c = paramMap.get('clProductId');
        applicationObj.genesis__CL_Purpose__c = paramMap.get('clPurposeId');
        applicationObj.genesis__Account__c = paramMap.get('borrowerAccountId');
        applicationObj.genesis__Contact__c = paramMap.get('borrowerContactId');
        applicationObj.Certified_Lender__c = paramMap.get('clAccountId');
        applicationObj.Signing_Method__c = 'Email - Docusign';
        return applicationObj;
    }   


    /**
    * @description Creating an Application Which is ACTIVATED for Previous Crop Year 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createPrevCropYearApplication(Map<String, Id> paramMap){
        Integer month = System.today().month();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '300023457';
        applicationObj.genesis__Status__c = 'ACTIVE';
        applicationObj.Reserved_Amount__c = 15000;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = true;
        if(month >= 6){
            applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        } else {
            applicationObj.Crop_Year__c = String.valueOf(System.today().year() - 1);
        }
        applicationObj.Dealer_Name__c = paramMap.get('dealerAccountId');
        applicationObj.genesis__CL_Product__c = paramMap.get('clProductId');
        applicationObj.genesis__CL_Purpose__c = paramMap.get('clPurposeId');
        applicationObj.genesis__Account__c = paramMap.get('borrowerAccountId');
        applicationObj.genesis__Contact__c = paramMap.get('borrowerContactId');
        applicationObj.Certified_Lender__c = paramMap.get('clAccountId');
        return applicationObj;
    } 


    /**
    * @description Creating Approved Application Note
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationObj 
    * @return genesis__Application_Note__c 
    **/
    public static genesis__Application_Note__c createApproveApplicationNote(genesis__Applications__c applicationObj){
        genesis__Application_Note__c appNoteObj = new genesis__Application_Note__c();
        appNoteObj.genesis__Application__c=applicationObj.Id;
        appNoteObj.Status__c=ConstantValues.APPLICATION_NOTE_APPROVE_STATUS;
        appNoteObj.Updated_Loan_Amount__c =425.00;
        appNoteObj.Current_Loan_Amount__c=4575.98;
        appNoteObj.Current_Maturity_Date__c=Date.today().addMonths(3);
        appNoteObj.Modified_Maturity_Date__c =Date.today().addMonths(6);
        return appNoteObj;
    }

    /**
    * @description Creating Declined Application Note
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationObj 
    * @return genesis__Application_Note__c 
    **/
    public static genesis__Application_Note__c createDeclineApplicationNote(genesis__Applications__c applicationObj){
        genesis__Application_Note__c appNoteObj = new genesis__Application_Note__c();
        appNoteObj.genesis__Application__c=applicationObj.Id;
        appNoteObj.Status__c=ConstantValues.APPLICATION_NOTE_DECLINE_STATUS;
        appNoteObj.Updated_Loan_Amount__c =425.00;
        appNoteObj.Current_Loan_Amount__c=4575.98;
        appNoteObj.Current_Maturity_Date__c=Date.today().addMonths(3);
        appNoteObj.Modified_Maturity_Date__c =Date.today().addMonths(6);
        return appNoteObj;
    }


    /**
    * @description Creating data for Party Type
    * @author Ayan Bhowmik | 02-22-2024 
    * @param name 
    * @return clcommon__Party_Type__c 
    **/
    public static clcommon__Party_Type__c createPartyType(String name) {
        clcommon__Party_Type__c partyTypeObj = new clcommon__Party_Type__c();
        partyTypeObj.Name= name;
        return partyTypeObj;
    }


    /**
    * @description Creating data for Party
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createParty(Map<String, Id> paramMap){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c=paramMap.get('accountId');
        partyObj.clcommon__Contact__c=paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        return partyObj;
    }


    /**
    * @description Creating Enabled Rate Card Setup Header for Current Year
    * @author Ayan Bhowmik | 02-22-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createCurrYearRateCardHeader(Account accountObj){
        Integer month;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = Date.newInstance(2022, 07, 01);
        rateCardHeaderObj.genesis__Transaction_Date__c = Date.newInstance(2022, 10, 15);
        rateCardHeaderObj.genesis__End_Date__c = Date.newInstance(2023, 09, 15);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        rateCardHeaderObj.genesis__Enabled_Flag__c = true;
        if(month >= 6){
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year());
        }
        return rateCardHeaderObj;
    }


    /**
    * @description Creating Enabled Rate Card Setup Header for Previous Year
    * @author Ayan Bhowmik | 02-22-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createPrevYearRateCardHeader(Account accountObj){
        Integer month;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = Date.newInstance(2022, 10, 01);
        rateCardHeaderObj.genesis__Transaction_Date__c = System.today();
        rateCardHeaderObj.genesis__End_Date__c = Date.newInstance(2022, 12, 01);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        rateCardHeaderObj.genesis__Enabled_Flag__c = true;
        if(month >= 6){
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year());
        } else {
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year() - 1);
        }
        return rateCardHeaderObj;
    }


    /**
    * @description Rate Card Setup Details for Current Year My Program
    * @author Ayan Bhowmik | 02-22-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetailOne(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0.2;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Start_Date__c = Date.newInstance(2022, 07, 01);
        rateCardDetailObj.End_Date__c = Date.newInstance(2022, 09, 30);
        rateCardDetailObj.genesis__Interest_Rate__c = 7.7;
        return rateCardDetailObj;
    }

    /**
    * @description Rate Card Setup Details for Prev Year My Program
    * @author Ayan Bhowmik | 02-22-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetailTwo(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 3;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Start_Date__c = Date.newInstance(2022, 10, 01);
        rateCardDetailObj.End_Date__c = Date.newInstance(2022, 12, 31);
        rateCardDetailObj.genesis__Interest_Rate__c = 2.5;
        return rateCardDetailObj;
    }


    /**
    * @description Creating Enabled Pricing Details
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationobj 
    * @param rateCardSetupDetailId 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    public static genesis__Application_Pricing_Detail__c createEnabledPricingDetail(genesis__Applications__c applicationobj,
                                                                                                Id rateCardSetupDetailId){
        genesis__Application_Pricing_Detail__c pricingDetailsObj = new genesis__Application_Pricing_Detail__c();
        pricingDetailsObj.genesis__Maximum_Financed_Amount__c = 15000;
        pricingDetailsObj.genesis__Rate_Factor_Based_On_Amount__c = 100;
        pricingDetailsObj.genesis__Rate_Factor__c = 0.00;
        pricingDetailsObj.genesis__Term__c = 12;
        pricingDetailsObj.genesis__Yield_Percent__c = 0.00;
        pricingDetailsObj.genesis__Application__c = applicationobj.Id;
        pricingDetailsObj.Loan_Number__c = applicationobj.genesis__Loan_Number__c + '-A';
        pricingDetailsObj.Loan_Id__c = '139001';
        pricingDetailsObj.Loan_Number__c = '300023457';
        pricingDetailsObj.Maturity_Date__c = Date.today().addYears(1);
        pricingDetailsObj.Interest_Per_Diem__c = 100;
        pricingDetailsObj.Fees__c = 100;
        pricingDetailsObj.genesis__Enabled_Flag__c = true;
        pricingDetailsObj.genesis__Rate_Card_Setup_Detail__c = rateCardSetupDetailId;
        return pricingDetailsObj;
    }


        /**
        * @description Creating Disabled Pricing Details
        * @author Ayan Bhowmik | 02-22-2024 
        * @param applicationobj 
        * @param rateCardSetupDetailId 
        * @return genesis__Application_Pricing_Detail__c 
        **/
        public static genesis__Application_Pricing_Detail__c createDisabledPricingDetail(genesis__Applications__c applicationobj,
                                                                                                Id rateCardSetupDetailId){
            genesis__Application_Pricing_Detail__c pricingDetailsObj = new genesis__Application_Pricing_Detail__c();
            pricingDetailsObj.genesis__Maximum_Financed_Amount__c = 15000;
            pricingDetailsObj.genesis__Rate_Factor_Based_On_Amount__c = 100;
            pricingDetailsObj.genesis__Rate_Factor__c = 0.00;
            pricingDetailsObj.genesis__Term__c = 12;
            pricingDetailsObj.genesis__Yield_Percent__c = 0.00;
            pricingDetailsObj.genesis__Application__c = applicationobj.Id;
            pricingDetailsObj.Loan_Number__c = applicationobj.genesis__Loan_Number__c + '-A';
            pricingDetailsObj.Loan_Id__c = '139001';
            pricingDetailsObj.Loan_Number__c = '300023457';
            pricingDetailsObj.Maturity_Date__c = Date.today().addYears(1);
            pricingDetailsObj.Interest_Per_Diem__c = 100;
            pricingDetailsObj.Fees__c = 100;
            pricingDetailsObj.genesis__Enabled_Flag__c = false;
            pricingDetailsObj.genesis__Rate_Card_Setup_Detail__c = rateCardSetupDetailId;
            return pricingDetailsObj;
        }


        /**
        * @description Creating Rate Card Set up Details for Rate Change Class on 45 and 32 days ahead
        * @author Ayan Bhowmik | 02-22-2024 
        * @param myProgramObj 
        * @param applicationObj 
        * @return List<genesis__Rate_Card_Setup_Detail__c> 
        **/
        public static List<genesis__Rate_Card_Setup_Detail__c> createFourtyFiveRateChngRateCards(genesis__Rate_Card_Setup_Header__c myProgramObj, 
                                                                                                    genesis__Applications__c applicationObj){
            List<genesis__Rate_Card_Setup_Detail__c> rateCards = new List<genesis__Rate_Card_Setup_Detail__c>();
            for(integer iterator =0; iterator < 2; iterator++){
                genesis__Rate_Card_Setup_Detail__c eachRate = new genesis__Rate_Card_Setup_Detail__c();
                eachRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                eachRate.genesis__Rate_Card_Setup_Header__c = myProgramObj.Id;
                eachRate.Interest_Rate_Type__c = 'VARIABLE';
                eachRate.Description__c = 'Seeds';
                if(iterator == 0){
                    eachRate.Start_Date__c = System.today();
                    eachrate.genesis__Interest_Rate__c = 2;
                    eachRate.End_Date__c = System.today().addDays(44);
                }else{
                    eachrate.genesis__Interest_Rate__c = 4;
                    eachRate.Start_Date__c = System.today().addDays(45);
                    eachRate.End_Date__c = myProgramObj.genesis__End_Date__c;
                }
                rateCards.add(eachRate);
            }
            return rateCards;
        }


        /**
        * @description Creating Rate Card Set up Details for Rate Change Class on 45 and 32 days ahead
        * @author Ayan Bhowmik | 02-22-2024 
        * @param myProgramObj 
        * @param applicationObj 
        * @return List<genesis__Rate_Card_Setup_Detail__c> 
        **/
        public static List<genesis__Rate_Card_Setup_Detail__c> createThirtyTwoRateChngRateCards(genesis__Rate_Card_Setup_Header__c myProgramObj, 
                                                                                                genesis__Applications__c applicationObj){
            List<genesis__Rate_Card_Setup_Detail__c> rateCards = new List<genesis__Rate_Card_Setup_Detail__c>();
            for(integer iterator = 0; iterator < 2; iterator++){
                genesis__Rate_Card_Setup_Detail__c eachRate = new genesis__Rate_Card_Setup_Detail__c();
                eachRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                eachRate.genesis__Rate_Card_Setup_Header__c = myProgramObj.Id;
                eachRate.Interest_Rate_Type__c = 'VARIABLE';
                eachRate.Description__c = 'Seeds';
                if(iterator == 0){
                    eachRate.Start_Date__c = System.today();
                    eachrate.genesis__Interest_Rate__c = 2;  
                    eachRate.End_Date__c = System.today().addDays(31);
                }else{
                    eachrate.genesis__Interest_Rate__c = 4;
                    eachRate.Start_Date__c = System.today().addDays(32);
                    eachRate.End_Date__c = myProgramObj.genesis__End_Date__c;
                }
                rateCards.add(eachRate);
            }
            return rateCards;
}


    /**
    * @description Creating Application Fees 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    * @param pricingDetailId 
    * @return genesis__Application_Fee_Payment__c 
    **/
    public static genesis__Application_Fee_Payment__c createApplicationFeePayment(Id applicationId,
                                                                                        Id pricingDetailId) {
        genesis__Application_Fee_Payment__c applicationFeePaymentObj = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentObj.External_Id__c = 'weqasweqwe1124';
        applicationFeePaymentObj.Pricing_Detail__c = pricingDetailId;
        applicationFeePaymentObj.Interest_Earned__c=10;
        applicationFeePaymentObj.Interest_Paid__c=10;
        applicationFeePaymentObj.Dealer_Monthly_Interest__c=10;
        applicationFeePaymentObj.Past_Due_Balance__c=10;
        applicationFeePaymentObj.Month__c=System.today().month();
        applicationFeePaymentObj.Year__c=System.today().year();
        applicationFeePaymentObj.genesis__Application__c = applicationId;
        applicationFeePaymentObj.Record_Type__c='PARTICIPANT DAILY';
        return applicationFeePaymentObj;
    }


    /**
    * @description Creating application fee payment subsidy
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    * @param pricingDetailId 
    * @return genesis__Application_Fee_Payment__c 
    **/
    public static genesis__Application_Fee_Payment__c createApplicationFeePaymentSubsidy(Id applicationId, Id pricingDetailId) {
        genesis__Application_Fee_Payment__c applicationFeePaymentObj = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentObj.genesis__Application__c = applicationId;
        applicationFeePaymentObj.Pricing_Detail__c = pricingDetailId;
        applicationFeePaymentObj.Year__c = System.today().year();
        applicationFeePaymentObj.Month__c = System.today().month();
        applicationFeePaymentObj.Record_Type__c = 'PARTICIPANT DAILY';
        return applicationFeePaymentObj;
    }


    /**
    * @description Creating Payment Mode for all type of Payment
    * @author Ayan Bhowmik | 02-22-2024 
    * @return Map<String, clcommon__Payment_Mode__c> 
    **/
    public static Map<String, clcommon__Payment_Mode__c> createPaymentMode() {
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = new Map<String, clcommon__Payment_Mode__c>();
        paymentModeMap.put('ACH', new clcommon__Payment_Mode__c(Name = 'ACH'));
        paymentModeMap.put('DRAFT', new clcommon__Payment_Mode__c(Name = 'DRAFT'));
        paymentModeMap.put('PAYMENT', new clcommon__Payment_Mode__c(Name = 'PAYMENT'));
        paymentModeMap.put('MOBILE DEPOSIT', new clcommon__Payment_Mode__c(Name = 'MOBILE DEPOSIT'));
        paymentModeMap.put('PRODUCT RETURN', new clcommon__Payment_Mode__c(Name = 'PRODUCT RETURN'));
        return paymentModeMap;
    }


    /**
    * @description Creating Funding Transaction Property
    * @author Ayan Bhowmik | 02-22-2024 
    * @param name 
    * @return clcommon__Funding_Transactions_Properties__c 
    **/
    public static clcommon__Funding_Transactions_Properties__c createFundingTransactionProperty(String name) {
        clcommon__Funding_Transactions_Properties__c fundingTransactionPropertyObj = new clcommon__Funding_Transactions_Properties__c();
        fundingTransactionPropertyObj.Name = name;
        return fundingTransactionPropertyObj;
    }


    /**
    * @description Creating Funding Transaction 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createACHFundingTransaction(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Application__c = paramMap.get('applicationId');
        fundingTransactionObj.Grower_Name__c = 'Test Grower 1';
        fundingTransactionObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        fundingTransactionObj.genesis__Amount__c = 1000;
        fundingTransactionObj.genesis__Payment_Mode__c = paramMap.get( 'paymentModeId');
        fundingTransactionObj.Batch__c = paramMap.get('fundingTransactionPropertyId');
        return fundingTransactionObj;
    }


     /**
     * @description Creating Funding Transaction Without Properties Batch
     * @author Ayan Bhowmik | 02-22-2024 
     * @param paramMap 
     * @return genesis__Funding_Transaction__c 
     **/
     public static genesis__Funding_Transaction__c createACHWithoutPropertiesBatch(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Application__c = paramMap.get('applicationId');
        fundingTransactionObj.Grower_Name__c = 'Test Grower 1';
        fundingTransactionObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        fundingTransactionObj.genesis__Amount__c = 1000;
        fundingTransactionObj.genesis__Payment_Mode__c = paramMap.get( 'paymentModeId');
        fundingTransactionObj.genesis__Cleared__c = false;
        return fundingTransactionObj;
    }


    /**
    * @description Creating Product Return Without Properties Batch
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createProductReturnWithoutPropertiesBatch(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Application__c = paramMap.get('applicationId');
        fundingTransactionObj.Grower_Name__c = 'Test Grower 1';
        fundingTransactionObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        fundingTransactionObj.genesis__Amount__c = 1000;
        fundingTransactionObj.genesis__Payment_Mode__c = paramMap.get( 'paymentModeId');
        fundingTransactionObj.genesis__Cleared__c = false;
        return fundingTransactionObj;
    }


    /**
    * @description Creating Funding Transaction 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param paramMap 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createDraftFundingTransaction(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c draftFundingTransactionObj = new genesis__Funding_Transaction__c();
        draftFundingTransactionObj.genesis__Application__c = paramMap.get('applicationId');
        draftFundingTransactionObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        draftFundingTransactionObj.genesis__Amount__c = 1000;
        draftFundingTransactionObj.genesis__Cleared__c = true;
        draftFundingTransactionObj.Grower_Name__c = 'Test Grower 1';
        draftFundingTransactionObj.genesis__Payment_Mode__c = paramMap.get('paymentModeId');
        return draftFundingTransactionObj;
    }

    /**
    * @description Fetching Cerfied Lender User
    * @author Ayan Bhowmik | 02-22-2024 
    * @param userName 
    * @return User 
    **/
    public static User getCertifiedLenderUser(String userName) {
        List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId IN (
                                        SELECT Id
                                            FROM Account
                                            WHERE Name = :userName)];
        if (userList.isEmpty()) {
            return null;
        }
        return userList[0];
    }

    /**
    * @description Fetching Cerfied Lender User Version 2
    * @author Ayan Bhowmik | 02-22-2024 
    * @param userName 
    * @return User 
    **/
    public static User getCertifiedLenderUserV2(String userName) {
        List<User> userList = [SELECT Id, AccountId, Account.ParentId
                                    FROM User
                                    WHERE AccountId IN (
                                        SELECT Id
                                            FROM Account
                                            WHERE Name = :userName)];
        if (userList.isEmpty()) {
            return null;
        }
        return userList[0];
    }

    /**
    * @description Fetching Borrower User
    * @author Ayan Bhowmik | 02-22-2024 
    * @param userName 
    * @return User 
    **/
    public static User getBorrowerUser(String userName) {
        List<User> borrowerUserList = [SELECT Id 
                                    FROM User 
                                    WHERE ContactId IN (
                                    SELECT Id 
                                    FROM Contact 
                                    WHERE LastName = :userName)];
                                    
        if (borrowerUserList.isEmpty()) {
            return null;
        } 
        return borrowerUserList[0];
    }

    /**
    * @description Creating Test Data for Landus Statement Code
    * @author Ayan Bhowmik | 02-22-2024 
    * @param dealerId 
    * @param certifiedLenderId 
    **/
    public static void createTestDataForLandusStatementCode(String dealerId, String certifiedLenderId) {
        List<genesis__Applications__c> applications = new List<genesis__Applications__c>{
                
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '22222',
                    Loan_Id__c = '22222',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '102555-LANDUS-OPT OUT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '33333',
                    Loan_Id__c = '33333',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '102555-LANDUS',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '44444',
                    Loan_Id__c = '44444',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '1',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '55555',
                    Loan_Id__c = '55555',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '6',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                )
            };
    
        Database.upsert(applications, true);

        List<genesis__Application_Pricing_Detail__c> childApplications = new List<genesis__Application_Pricing_Detail__c> {
            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[1].Id,
                genesis__Enabled_Flag__c = true
            )
        };

        Database.upsert(childApplications, true);
    }

    /**
    * @description Creating Test Data for CFA Statement Code
    * @author Ayan Bhowmik | 02-22-2024 
    * @param dealerId 
    * @param certifiedLenderId 
    **/
    public static void createTestDataForCFAStatementCode(String dealerId, String certifiedLenderId) {
        List<genesis__Applications__c> applications = new List<genesis__Applications__c>{
                
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '22222',
                    Loan_Id__c = '22222',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'COMMITMENT-OPT OUT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '33333',
                    Loan_Id__c = '33333',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'COMMITMENT STATEMENT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '44444',
                    Loan_Id__c = '44444',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'MONTHLY-OPT OUT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '55555',
                    Loan_Id__c = '55555',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'MONTHLY STATEMENT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                )
            };
    
        Database.upsert(applications, true);

        List<genesis__Application_Pricing_Detail__c> childApplications = new List<genesis__Application_Pricing_Detail__c> {
            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[1].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[2].Id,
                genesis__Enabled_Flag__c = true
            )
        };

        Database.upsert(childApplications, true);
    }
    /**
    * @description Creating Test Data for Loan Product
    * @author Ayan Bhowmik | 02-22-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createLoanProduct(){
        clcommon__CL_Product__c productObj = new clcommon__CL_Product__c();
        productObj.clcommon__Product_Name__c = PortalConstants.SIMPLIFY_TYPE;
        RecordType recordTypeId = [SELECT Id, 
                                            Name, 
                                            SobjectType, 
                                            DeveloperName, 
                                            NamespacePrefix 
                                        FROM RecordType 
                                        WHERE Name = 'Loan' AND 
                                            SobjectType = 'clcommon__CL_Product__c'];
        productObj.RecordTypeId = recordTypeId.Id;
        return productObj;
    }
    /**
    * @description Creating Test Data for Rate Card Setup Header
    * @author Ayan Bhowmik | 02-22-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createRateCardSetupHeader(Account accountObj){
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Crop_Year__c = '2024';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = System.today();
        rateCardHeaderObj.genesis__Transaction_Date__c = System.today();
        String endDateStr = '03/15/2025';
        rateCardHeaderObj.genesis__End_Date__c = Date.parse(endDateStr);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        return rateCardHeaderObj;
    }
    /**
    * @description Creating Test Data for Rate Card Product Association
    * @author Ayan Bhowmik | 02-22-2024 
    * @param product 
    * @param rateCard 
    * @return genesis__Product_Rate_Card_Association__c 
    **/
    public static genesis__Product_Rate_Card_Association__c createRateToProductAssociation(clcommon__CL_Product__c product, genesis__Rate_Card_Setup_Header__c rateCard){
        genesis__Product_Rate_Card_Association__c rateToProduct = new genesis__Product_Rate_Card_Association__c();
        rateToProduct.genesis__CL_Product__c = product.Id;
        rateToProduct.genesis__Rate_Card_Setup__c = rateCard.Id;
        return rateToProduct;
    }
    /**
    * @description Creating Test Data for Additional Factor for Program
    * @author Ayan Bhowmik | 02-22-2024 
    * @param rateCardHeader 
    * @return genesis__Additional_Determining_Factor__c 
    **/
    public static genesis__Additional_Determining_Factor__c createAdditionalFactorForProgram(genesis__Rate_Card_Setup_Header__c rateCardHeader){
        genesis__Additional_Determining_Factor__c factor = new genesis__Additional_Determining_Factor__c();
        factor.genesis__Field_Value__c = rateCardHeader.Name;
        factor.Name = PortalConstants.MY_PROGRAM_FACTOR_NAME;
        factor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        factor.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        factor.genesis__Applicable_for_Application__c = true;
        factor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        factor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        factor.genesis__Application_Field_API_Name__c = PortalConstants.MY_PROGRAM_FIELD_API_NAME;
        factor.genesis__Application_Field_Name__c = PortalConstants.MY_PROGRAM_FIELD_NAME;
        factor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        factor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        return factor;
    }
     /**
     * @description Creating Test Data for Additional Factor for Dealer
     * @author Ayan Bhowmik | 02-22-2024 
     * @param rateCardHeader 
     * @return genesis__Additional_Determining_Factor__c 
     **/
     public static genesis__Additional_Determining_Factor__c createAdditionalFactorForDealer(genesis__Rate_Card_Setup_Header__c rateCardHeader){
        genesis__Additional_Determining_Factor__c factor = new genesis__Additional_Determining_Factor__c();
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id = :rateCardHeader.Account__c];
        factor.genesis__Field_Value__c = accountObj.Name;
        factor.Name = PortalConstants.DEALER_PROFILE;
        factor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        factor.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        factor.genesis__Applicable_for_Application__c = true;
        factor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        factor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        factor.genesis__Application_Field_API_Name__c = PortalConstants.MY_PROGRAM_DEALER_FIELD;
        factor.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
        factor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        factor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        return factor;
    }
    /**
    * @description Creating Test Data for Rate Card Setup Detail
    * @author Ayan Bhowmik | 02-22-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createNewRateCardSetupDetail(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 2;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        String startDateStr = '08/08/2023';
        Date startDate = Date.parse(startDateStr);
        String endDateStr = '03/15/2025';
        Date endDate = Date.parse(endDateStr);
        rateCardDetailObj.Start_Date__c = startDate;
        rateCardDetailObj.End_Date__c = endDate;
        rateCardDetailObj.genesis__Interest_Rate__c = 6.5;
        return rateCardDetailObj;
    }
    /**
    * @description Creating Test Data for DBA Account.
    * @author Ayan Bhowmik | 02-22-2024 
    * @param businessInfo 
    * @return Account 
    **/
    public static Account createDBAccount(genesis__Business_Information__c businessInfo ){  
        Account accountObj = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.Name='Individual(s) with DBA';
        clEntity.clcommon__Legal_Entity_Type__c='Individual(s) with DBA';
        accountObj.Name='SJha';
        accountObj.CIF_Number__c='123456';
        accountObj.BillingCity='San Mateo';
        accountObj.Short_Name__c='San';
        accountObj.BillingState='CA';
        accountObj.BillingStreet='Waters Park Drive';
        accountObj.BillingPostalCode='41223';
        Database.insert(clEntity,true);
        accountObj.clcommon__Legal_Entity_Type__c = clEntity.Id;
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        return accountObj;
    }
    /**
    * @description Creating Test Data for Flex Rate Application
    * @author Ayan Bhowmik | 02-22-2024 
    * @param clProduct 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForFlex(clcommon__CL_Product__c clProduct, Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Term__c = 19;
        applicationObj.genesis__Interest_Rate__c = 1.45;
        applicationObj.genesis__Loan_Amount__c = 7685;
        applicationObj.genesis__CL_Product__c = clProduct.Id;
        return applicationObj;
    }


    /**
    * @description Creating the Credit Rating Matrix
    * @author Ayan Bhowmik | 02-22-2024 
    * @return List<genesis__Credit_Rating_Matrix__c> 
    **/
    public static List<genesis__Credit_Rating_Matrix__c> createCreditRatingMatrix() {
        List<genesis__Credit_Rating_Matrix__c> creditRatingList = new List<genesis__Credit_Rating_Matrix__c>();
        for (Integer index = 1; index <= 4; index++) {
            genesis__Credit_Rating_Matrix__c creditRating = new genesis__Credit_Rating_Matrix__c(Name='Tier ' + index);
            creditRatingList.add(creditRating);
        }
        Database.insert(creditRatingList, true); 
        return creditRatingList;
    }

    /**
    * @description Creating Test Data for Application Setup Data
    * @author Ayan Bhowmik | 02-22-2024 
    * @param clContact 
    * @param dealerContact 
    * @param clProductId 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationSetupData(
            Contact clContact, 
            Contact dealerContact, 
            String clProductId
        ) {

        genesis__Credit_Rating_Matrix__c rating = new genesis__Credit_Rating_Matrix__c(Name='Tier 1');
        Database.insert(rating, true);

        // create legal entity
        clcommon__Legal_Entity__c individualSolePropEntity = createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(individualSolePropEntity, true);

        genesis__Business_Information__c borrowerBusinessInfo = createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfo, true);
        
        // create borrower account
        Account borrowerAccount = createSolePropAccount(individualSolePropEntity, (Id) borrowerBusinessInfo.Id);
        borrowerAccount.CIF_Number__c = '677654';
        Database.insert(borrowerAccount, true);

        // create borrower contact
        Contact borrowerContact = createBorrowerContact(borrowerAccount.Id);
        Database.insert(borrowerContact, true);

        genesis__Business_Information__c principalBusinessInfo = createBusinessInfoForBorrower();
        Database.insert(principalBusinessInfo, true);

        // create principal account
        Account principalAccount = createSolePropAccount(individualSolePropEntity, (Id) principalBusinessInfo.Id);
        principalAccount.Name = 'Rishi Bose';
        Database.insert(principalAccount, true);

        // create principal contact
        Contact principalContact = createBorrowerContact(principalAccount.Id);
        principalContact.FirstName = 'Rishi';
        principalContact.LastName = 'Bose';
        Database.insert(principalContact, true);

        clcommon__CL_Purpose__c objCLPurpose = TestClassHelper.createCLPurposeForApplication();
        Database.insert(objCLPurpose, true);

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Contact__c = borrowerContact.Id;
        application.genesis__Product_Type__c = 'Package';
        application.genesis__Term__c = 12;
        application.genesis__Interest_Rate__c = 8;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__CL_Product__c = clProductId;
        application.genesis__CL_Purpose__c = objCLPurpose.Id;
        application.genesis__Status__c = 'NEW - SCORECARD GENERATED';
        application.Certified_Lender__c = clContact.AccountId;
        application.Dealer_Name__c = dealerContact.AccountId;
        application.genesis__Loan_Number__c = '11223344';
        application.Signing_Method__c = 'In Person - Docusign';
        application.genesis__Credit_Rating__c = rating.Id;


        Database.insert(application, true);

        clcommon__Party_Type__c borrowerPartyType = new clcommon__Party_Type__c(Name = 'BORROWER');
        clcommon__Party_Type__c principalPartyType = new clcommon__Party_Type__c(Name = 'PRINCIPAL');
        clcommon__Party_Type__c dealerPartyType = new clcommon__Party_Type__c(Name = 'DEALER');
        clcommon__Party_Type__c clPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER');
        clcommon__Party_Type__c clPlusPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER PLUS');
        clcommon__Party_Type__c saPartyType = new clcommon__Party_Type__c(Name = 'SALES AGENT');
        clcommon__Party_Type__c saPlusPartyType = new clcommon__Party_Type__c(Name = 'SALES AGENT PLUS');
        clcommon__Party_Type__c inqPartyType = new clcommon__Party_Type__c(Name = 'INQUIRY');
        clcommon__Party_Type__c inqPlusPartyType = new clcommon__Party_Type__c(Name = 'INQUIRY PLUS');

        Database.insert(new List<clcommon__Party_Type__c>{
                            borrowerPartyType,
                            principalPartyType,
                            dealerPartyType,
                            clPartyType,
                            clPlusPartyType,
                            saPartyType,
                            saPlusPartyType,
                            inqPartyType,
                            inqPlusPartyType
                        }, true);

        List<clcommon__Party__c> parties = new List<clcommon__Party__c> {
            new clcommon__Party__c(
                // clcommon__Party_Types__c = 'Individual',
                clcommon__Account__c = clContact.AccountId,
                clcommon__Contact__c = clContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = clPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = 'DEALER',
                clcommon__Account__c = dealerContact.AccountId,
                clcommon__Contact__c = dealerContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = dealerPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = 'BORROWER',
                clcommon__Account__c = borrowerAccount.Id,
                clcommon__Contact__c = borrowerContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = borrowerPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = 'PRINCIPAL',
                clcommon__Account__c = principalAccount.Id,
                clcommon__Contact__c = principalContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = principalPartyType.Id
            )
        };

        Database.insert(parties, true);       

        return application;
    }

    
    /**
    * @description Creating Test Data for Application Setup Data
    * @author Ayan Bhowmik | 02-22-2024 
    * @param params 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationSetupData(
            Map<String, Object> params
        ) {

        Account borrowerAccount = (Account) params.get('borrowerAccount');
        Contact borrowerContact = (Contact) params.get('borrowerContact');
        Contact clContact = (Contact) params.get('clContact');
        Contact dealerContact = (Contact) params.get('dealerContact');
        Id clProductId = (Id) params.get('clProductId');

        genesis__Credit_Rating_Matrix__c rating = new genesis__Credit_Rating_Matrix__c(Name='Tier 1');
        Database.insert(rating, true);

        // // create legal entity
        // clcommon__Legal_Entity__c individualSolePropEntity = createLegalEntity('Individual(s) - Sole Proprietorship');
        // Database.insert(individualSolePropEntity, true);

        // genesis__Business_Information__c borrowerBusinessInfo = createBusinessInfoForBorrower();
        // Database.insert(borrowerBusinessInfo, true);
        
        // // create borrower account
        // Account borrowerAccount = createSolePropAccount(individualSolePropEntity, (Id) borrowerBusinessInfo.Id);
        // borrowerAccount.CIF_Number__c = '332211';
        // Database.insert(borrowerAccount, true);

        // // create borrower contact
        // Contact borrowerContact = createBorrowerContact(borrowerAccount.Id);
        // Database.insert(borrowerContact, true);

        clcommon__CL_Purpose__c objCLPurpose = TestClassHelper.createCLPurposeForApplication();
        Database.insert(objCLPurpose, true);

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Contact__c = borrowerContact.Id;
        application.genesis__Product_Type__c = 'Package';
        application.genesis__Term__c = 12;
        application.genesis__Interest_Rate__c = 8;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__CL_Product__c = clProductId;
        application.genesis__CL_Purpose__c = objCLPurpose.Id;
        application.genesis__Status__c = 'NEW - SCORECARD GENERATED';
        application.Certified_Lender__c = clContact.AccountId;
        application.Dealer_Name__c = dealerContact.AccountId;
        application.genesis__Loan_Number__c = '11223344';
        application.Signing_Method__c = 'In Person - Docusign';
        application.genesis__Credit_Rating__c = rating.Id;


        Database.insert(application, true);

        clcommon__Party_Type__c borrowerPartyType = new clcommon__Party_Type__c(Name = 'BORROWER');
        clcommon__Party_Type__c dealerPartyType = new clcommon__Party_Type__c(Name = 'DEALER');
        clcommon__Party_Type__c clPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER');
        clcommon__Party_Type__c clPlusPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER PLUS');
        clcommon__Party_Type__c saPartyType = new clcommon__Party_Type__c(Name = 'SALES AGENT');
        clcommon__Party_Type__c saPlusPartyType = new clcommon__Party_Type__c(Name = 'SALES AGENT PLUS');
        clcommon__Party_Type__c inqPartyType = new clcommon__Party_Type__c(Name = 'INQUIRY');
        clcommon__Party_Type__c inqPlusPartyType = new clcommon__Party_Type__c(Name = 'INQUIRY PLUS');

        Database.insert(new List<clcommon__Party_Type__c>{
                            borrowerPartyType,
                            dealerPartyType,
                            clPartyType,
                            clPlusPartyType,
                            saPartyType,
                            saPlusPartyType,
                            inqPartyType,
                            inqPlusPartyType
                        }, true);

        List<clcommon__Party__c> parties = new List<clcommon__Party__c> {
            new clcommon__Party__c(
                // clcommon__Party_Types__c = 'CERTIFIED LENDER',
                clcommon__Account__c = clContact.AccountId,
                clcommon__Contact__c = clContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = clPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = 'DEALER',
                clcommon__Account__c = dealerContact.AccountId,
                clcommon__Contact__c = dealerContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = dealerPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = 'BORROWER',
                clcommon__Account__c = borrowerAccount.Id,
                clcommon__Contact__c = borrowerContact.Id,
                genesis__Application__c = application.Id,
                clcommon__Type__c = borrowerPartyType.Id

            )
        };

        Database.insert(parties, true);       

        return application;
    }

    /**
    * @description Creating Test Data for Growmark My Program
    * @author Kabir Pramanik | 12-10-2024 
    * @param dealerId 
    **/
    public static void createTestDataForGrowmarkMyProgram(String dealerId) {
        genesis__Rate_Card_Setup_Header__c rateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeader.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);//Date.valueOf('2024-03-15');
        rateCardHeader.Name = 'GMK My Program - 110';
        rateCardHeader.Crop_Year__c = '2023';
        rateCardHeader.FS_Index_Rate__c = 8.75;
        rateCardHeader.CFA_Advantage_Rate__c = 11.5;
        rateCardHeader.Closing_Fee__c = 0;
        rateCardHeader.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeader.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeader.Dealer_Participate_on_Closing_Fee__c = 'No';
        rateCardHeader.Account__c = dealerId;
        rateCardHeader.genesis__Start_Date__c = System.today();
        rateCardHeader.genesis__Transaction_Date__c = System.today();

        Database.insert(rateCardHeader, true);

        clcommon__CL_Product__c objProductToAssociate = [SELECT Id, 
                                                                Name, 
                                                                RecordType.Name, 
                                                                clcommon__Product_Name__c, 
                                                                clcommon__Pricing_Method__c 
                                                        FROM clcommon__CL_Product__c 
                                                        WHERE RecordType.Name = :PortalConstants.LOAN_STRING 
                                                            AND clcommon__Product_Name__c =:PortalConstants.SIMPLIFY_TYPE 
                                                        LIMIT 1];
                                                        
        genesis__Product_Rate_Card_Association__c objRateToProductAssoc = new genesis__Product_Rate_Card_Association__c();
        objRateToProductAssoc.genesis__CL_Product__c = objProductToAssociate.Id;
        objRateToProductAssoc.genesis__Rate_Card_Setup__c = rateCardHeader.Id;
        Database.upsert(objRateToProductAssoc, true);

        genesis__Additional_Determining_Factor__c additionalFactor = new genesis__Additional_Determining_Factor__c();
        additionalFactor = TestClassHelper.createAdditionalFactor(rateCardHeader);
        
        //Additional Factor for dealer check
        genesis__Additional_Determining_Factor__c additionalFactorDealer = new genesis__Additional_Determining_Factor__c();
        additionalFactorDealer = TestClassHelper.createAdditionalFactorDealer(rateCardHeader);

        genesis__Rate_Card_Setup_Detail__c noteRateAA = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAA.Start_Date__c = System.today();
        noteRateAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        noteRateAA.Participation_Percentage_Dealer_Subsidy__c = 0;
        noteRateAA.Participation_Percentage_Dealer__c = 1.25;
        noteRateAA.Participation_Percentage_CFA__c = 0;
        noteRateAA.genesis__Interest_Rate__c = 10;
        noteRateAA.Interest_Rate_Type__c = 'Fixed';
        noteRateAA.Description__c = 'Note Rate';
        noteRateAA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAA.Special_Term_Order__c = 1;
        noteRateAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAB = new genesis__Rate_Card_Setup_Detail__c();
        
        noteRateAB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        noteRateAB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        noteRateAB.Participation_Percentage_Dealer_Subsidy__c = 0.75;
        noteRateAB.Participation_Percentage_Dealer__c = 0;
        noteRateAB.Participation_Percentage_CFA__c = 0;
        noteRateAB.genesis__Interest_Rate__c = 8;
        noteRateAB.Interest_Rate_Type__c = 'Variable';
        noteRateAB.Description__c = 'Note Rate';
        noteRateAB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAB.Special_Term_Order__c = 1;
        noteRateAB.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAC = new genesis__Rate_Card_Setup_Detail__c();

        noteRateAC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        noteRateAC.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        noteRateAC.Participation_Percentage_Dealer_Subsidy__c = 0.75;
        noteRateAC.Participation_Percentage_Dealer__c = 0;
        noteRateAC.Participation_Percentage_CFA__c = 0;
        noteRateAC.genesis__Interest_Rate__c = 8;
        noteRateAC.Interest_Rate_Type__c = 'Fixed';
        noteRateAC.Description__c = 'Note Rate';
        noteRateAC.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAC.Special_Term_Order__c = 1;
        noteRateAC.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';



        genesis__Rate_Card_Setup_Detail__c specialTermBA = new genesis__Rate_Card_Setup_Detail__c();

        specialTermBA.Start_Date__c = System.today();
        specialTermBA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermBA.Participation_Percentage_Dealer_Subsidy__c = 0.75;
        specialTermBA.Participation_Percentage_Dealer__c = 0;
        specialTermBA.Participation_Percentage_CFA__c = 0;
        specialTermBA.genesis__Interest_Rate__c = 8;
        specialTermBA.Interest_Rate_Type__c = 'Fixed';
        specialTermBA.Description__c = 'Seeds';
        specialTermBA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        specialTermBA.Special_Term_Order__c = 1;
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBB = new genesis__Rate_Card_Setup_Detail__c();

        specialTermBB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermBB.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermBB.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBB.Participation_Percentage_Dealer__c = 0.25;
        specialTermBB.Participation_Percentage_CFA__c = 0;
        specialTermBB.genesis__Interest_Rate__c = 9;
        specialTermBB.Interest_Rate_Type__c = 'Variable';
        specialTermBB.Description__c = 'Seeds';
        specialTermBB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        specialTermBB.Special_Term_Order__c = 2;
        specialTermBB.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c> {noteRateAA, noteRateAB, noteRateAC, specialTermBA, specialTermBB}, true);
        
    }


    /**
    * @description Creating Test Data for CFA My Program
    * @author Kabir Pramanik | 12-10-2024 
    * @param dealerId 
    **/
    public static void createTestDataForCFAMyProgram(String dealerId) {
        genesis__Rate_Card_Setup_Header__c rateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeader.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        rateCardHeader.Name = 'CFA My Program - 110';
        rateCardHeader.Crop_Year__c = '2023';
        rateCardHeader.FS_Index_Rate__c = 8.75;
        rateCardHeader.CFA_Advantage_Rate__c = 11.5;
        rateCardHeader.Closing_Fee__c = 200;
        rateCardHeader.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeader.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeader.Dealer_Participate_on_Closing_Fee__c = 'No';
        rateCardHeader.Account__c = dealerId;
        rateCardHeader.genesis__Start_Date__c = System.today();
        rateCardHeader.genesis__Transaction_Date__c = System.today();

        Database.insert(rateCardHeader, true);

        clcommon__CL_Product__c objProductToAssociate = [SELECT Id, 
                                                                Name, 
                                                                RecordType.Name, 
                                                                clcommon__Product_Name__c, 
                                                                clcommon__Pricing_Method__c 
                                                        FROM clcommon__CL_Product__c 
                                                        WHERE RecordType.Name = :PortalConstants.LOAN_STRING 
                                                            AND clcommon__Product_Name__c =:PortalConstants.SIMPLIFY_TYPE 
                                                        LIMIT 1];
                                                        
        genesis__Product_Rate_Card_Association__c objRateToProductAssoc = new genesis__Product_Rate_Card_Association__c();
        objRateToProductAssoc.genesis__CL_Product__c = objProductToAssociate.Id;
        objRateToProductAssoc.genesis__Rate_Card_Setup__c = rateCardHeader.Id;
        Database.upsert(objRateToProductAssoc, true);

        genesis__Additional_Determining_Factor__c additionalFactor = new genesis__Additional_Determining_Factor__c();
        additionalFactor = TestClassHelper.createAdditionalFactor(rateCardHeader);
        
        //Additional Factor for dealer check
        genesis__Additional_Determining_Factor__c additionalFactorDealer = new genesis__Additional_Determining_Factor__c();
        additionalFactorDealer = TestClassHelper.createAdditionalFactorDealer(rateCardHeader);

        genesis__Rate_Card_Setup_Detail__c noteRateAA = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAA.Start_Date__c = System.today();
        noteRateAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        noteRateAA.Participation_Percentage_Dealer_Subsidy__c = 0.75;
        noteRateAA.Participation_Percentage_Dealer__c = 0;
        noteRateAA.Participation_Percentage_CFA__c = 0.75;
        noteRateAA.genesis__Interest_Rate__c = 10;
        noteRateAA.Interest_Rate_Type__c = 'Fixed';
        noteRateAA.Description__c = 'Note Rate';
        noteRateAA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAA.Special_Term_Order__c = 1;
        noteRateAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAB = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        noteRateAB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        noteRateAB.Participation_Percentage_Dealer_Subsidy__c = 0;
        noteRateAB.Participation_Percentage_Dealer__c = 0.5;
        noteRateAB.Participation_Percentage_CFA__c = 0;
        noteRateAB.genesis__Interest_Rate__c = 12;
        noteRateAB.Interest_Rate_Type__c = 'Variable';
        noteRateAB.Description__c = 'Note Rate';
        noteRateAB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAB.Special_Term_Order__c = 1;
        noteRateAB.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAC = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        noteRateAC.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        noteRateAC.Participation_Percentage_Dealer_Subsidy__c = 2;
        noteRateAC.Participation_Percentage_Dealer__c = 0;
        noteRateAC.Participation_Percentage_CFA__c = 1.5;
        noteRateAC.genesis__Interest_Rate__c = 8;
        noteRateAC.Interest_Rate_Type__c = 'Fixed';
        noteRateAC.Description__c = 'Note Rate';
        noteRateAC.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAC.Special_Term_Order__c = 1;
        noteRateAC.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';



        genesis__Rate_Card_Setup_Detail__c specialTermBA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBA.Start_Date__c = System.today();
        specialTermBA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermBA.Participation_Percentage_Dealer_Subsidy__c = 2;
        specialTermBA.Participation_Percentage_Dealer__c = 0;
        specialTermBA.Participation_Percentage_CFA__c = 1.5;
        specialTermBA.genesis__Interest_Rate__c = 8;
        specialTermBA.Interest_Rate_Type__c = 'Fixed';
        specialTermBA.Description__c = 'Seeds';
        specialTermBA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        specialTermBA.Special_Term_Order__c = 1;
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBB = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermBB.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermBB.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBB.Participation_Percentage_Dealer__c = 0.5;
        specialTermBB.Participation_Percentage_CFA__c = 0;
        specialTermBB.genesis__Interest_Rate__c = 12;
        specialTermBB.Interest_Rate_Type__c = 'Variable';
        specialTermBB.Description__c = 'Seeds';
        specialTermBB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        specialTermBB.Special_Term_Order__c = 2;
        specialTermBB.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c> {noteRateAA, noteRateAB, noteRateAC, specialTermBA, specialTermBB}, true);
        
    }
    /**
    * @description Creating Test Data for Task
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    * @param subject 
    * @return Task 
    **/
    public static Task createTask(Id applicationId, String subject){
        Task taskObj = new Task();
        taskObj.genesis__Application__c = applicationId;
        taskObj.Subject = subject;
        taskObj.Comments__c = 'this is a test comment';
        return taskObj;
    }
    /**
    * @description Creating Test Data for Bank Account
    * @author Ayan Bhowmik | 02-22-2024 
    * @param dealerAccountid 
    * @return clcommon__Bank_Account__c 
    **/
    public static clcommon__Bank_Account__c createBankAccount(Id dealerAccountid){
        clcommon__Bank_Account__c bankInfo = new clcommon__Bank_Account__c();
        bankInfo.clcommon__Bank_Account_Number__c = '5003101002225';
        bankInfo.clcommon__Bank_Account_Name__c = 'Sam Grower';
        bankInfo.clcommon__Routing_Number__c = '322078804';
        bankInfo.clcommon__Account__c = dealerAccountid;
        bankInfo.clcommon__Bank_Name__c = 'FINANCIAL PARTNERS CREDIT UNION';
        bankInfo.clcommon__Active__c = true;
        bankInfo.ACH_Debit__c = true;
        bankInfo.ACH_Credit__c = true;
        return bankInfo;
    }

    /**
    * @description Creating Test Data for Task
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    **/
    public static void createSetupDateForTasks(Id applicationId) {

        List<Task> tasks = new List<Task> {
            new Task(Subject='Customized Loan Approval', genesis__Application__c=applicationId),
            new Task(Subject='Assignment of Insurance', genesis__Application__c=applicationId),
            new Task(Subject='Notice of Security Interest (CFA Action)', genesis__Application__c=applicationId),
            new Task(Subject='Additional Information Form', genesis__Application__c=applicationId),
            new Task(Subject='Entity Documents', genesis__Application__c=applicationId),
            new Task(Subject='Spousal Consent', genesis__Application__c=applicationId),
            new Task(Subject='Notice of Security Interest', genesis__Application__c=applicationId),
            new Task(Subject='Withdrawal Form', genesis__Application__c=applicationId)
        };

        Database.insert(tasks, true);
    }

    /**
    * @description Creating Test Data for Collateral
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    **/
    public static void createSetupDataForCollateral(Id applicationId) {
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

        Database.insert(prices, true);

        List<clcommon__collateral__c> collaterals = new List<clcommon__collateral__c>();

        List<clcommon__Collateral_Category__c> commodityList = [
                        SELECT Id, 
                               Price_Per_Unit_2__c
                        FROM clcommon__Collateral_Category__c 
                        WHERE Name IN ('Soybean','Corn')
                    ];
        
        collaterals.add(TestClassHelper.createCollateral((String) commodityList[0].Id, 1000, 500, 250, 'YP', '50%', null));

        collaterals[0].genesis__Application__c = applicationId;
        collaterals[0].Price__c = commodityList[0].Price_Per_Unit_2__c;
        // collaterals[0].Total_Collateral_Price__c = 60000;
        Database.insert(collaterals, true);

        List<clcommon__collateral__c> collateralList = [
            SELECT id, Total_Collateral_Price__c, price__c
            FROM clcommon__collateral__c
            LIMIT 1
        ];
        collateralList[0].price__c = commodityList[0].Price_Per_Unit_2__c;
        Database.upsert(collateralList, true);
    }

    /**
    * @description Creating Additional Test Data for Application
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    **/
    public static void createAdditionalDataForApplication(Id applicationId) {
        clcommon__Party_Type__c spousePartyType = new clcommon__Party_Type__c(Name = PortalConstants.SPOUSE_PARTY_NAME);
        clcommon__Party_Type__c landOwnerPartyType = new clcommon__Party_Type__c(Name = PortalConstants.LANDOWNER_PARTY_NAME);
        clcommon__Party_Type__c buyerPartyType = new clcommon__Party_Type__c(Name = PortalConstants.BUYER_PARTY_NAME);
        clcommon__Party_Type__c insuranceAgentPartyType = new clcommon__Party_Type__c(Name = PortalConstants.INSURANCE_AGENT_PARTY_NAME);

        genesis__Business_Information__c additionalBusinessInfo = new genesis__Business_Information__c();
        Account additionalAccount = createAccount(additionalBusinessInfo.Id);
        Contact additionalContact = createContactWithAccountObject(additionalAccount);

        Database.insert(new List<clcommon__Party_Type__c>{
                            spousePartyType,
                            landOwnerPartyType,
                            buyerPartyType,
                            insuranceAgentPartyType
                        }, true);

        List<clcommon__Party__c> parties = new List<clcommon__Party__c> {
            new clcommon__Party__c(
                clcommon__Party_Types__c = PortalConstants.INSURANCE_AGENT_PARTY_NAME,
                clcommon__Account__c = additionalAccount.Id,
                clcommon__Contact__c = additionalContact.Id,
                genesis__Application__c = applicationId,
                clcommon__Type__c = insuranceAgentPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = PortalConstants.BUYER_PARTY_NAME,
                clcommon__Account__c = additionalAccount.Id,
                clcommon__Contact__c = additionalContact.Id,
                genesis__Application__c = applicationId,
                clcommon__Type__c = buyerPartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = PortalConstants.SPOUSE_PARTY_NAME,
                clcommon__Account__c = additionalAccount.Id,
                clcommon__Contact__c = additionalContact.Id,
                genesis__Application__c = applicationId,
                clcommon__Type__c = spousePartyType.Id
            ),

            new clcommon__Party__c(
                clcommon__Party_Types__c = PortalConstants.LANDOWNER_PARTY_NAME,
                clcommon__Account__c = additionalAccount.Id,
                clcommon__Contact__c = additionalContact.Id,
                genesis__Application__c = applicationId,
                clcommon__Type__c = landOwnerPartyType.Id
            )
        };

        Database.insert(parties, true);    
    }


    /**
    * @description Creating Test Data for Collateral Category
    * @author Ayan Bhowmik | 02-22-2024 
    * @return clcommon__Collateral_Category__c 
    **/
    public static clcommon__Collateral_Category__c createCollateralCategory(){
        clcommon__Collateral_Category__c collateral = new clcommon__Collateral_Category__c();
        collateral.name = 'Millet';
        collateral.Collateral_Unit__c = 'BU';
        collateral.Price_Per_Unit_1__c = 10.85;
        collateral.Price_Per_Unit_2__c = 6.85;
        collateral.Commodity_Display_Position__c = 7;
        return collateral;
    }
    /**
    * @description Creating Test Data for Collateral 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param collateralDetailsMap 
    * @return clcommon__collateral__c 
    **/
    public static clcommon__collateral__c createCollateral(Map<String,String> collateralDetailsMap){
         return new clcommon__collateral__c(clcommon__Collateral_Category__c= collateralDetailsMap.get('collateralCategoryId'),
                                            clcommon__Collateral_Name__c='commodity',
                                            Total_Acres__c= 20,
                                            Producer_Share_Percent__c= 50,
                                            Approved_Yield__c= 15,
                                            Insurance_Plan__c=collateralDetailsMap.get('insurancePlan'),
                                            Percent_Coverage_Level__c=collateralDetailsMap.get('percentCoverageLevel'),
                                            Percent_Fed__c= 12);
    }

    /**
    * @description Creating Test Data for Funding Transaction
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objPaymentMode 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createFundingTransaction(clcommon__Payment_Mode__c objPaymentMode){
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Payment_Mode__c = objPaymentMode.Id;
        objFundingTransaction.genesis__Funding_Date__c = date.today();
        objFundingTransaction.genesis__Amount__c = 1500;
        objFundingTransaction.genesis__Reference__c = 'Crop';
        return objFundingTransaction;
    }

    /**
    * @description : method to create cfaAdminuser
    * @author Suraj Kumar | 05-07-2024 
    * @return user 
    **/
    public static user createCfaAdminUser(){
        Profile cfaProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'CFA Admin User'
                                    LIMIT 1];
        User objUser = new User(
                    Alias = 'newUser', 
                    Email='cfaadminuser@yopmail.com',
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = cfaProfileObj.Id, 
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName='cfaadminuser@yopmail.com',
                    User_Number__c = 11223344
                );
        return objUser;
    }
}