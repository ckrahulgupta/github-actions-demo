/**
 * @description       : Test helper class for fico
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayan Bhowmik
**/
@isTest
public class FICOCalloutTestHelper {
    /**
    * @description Creating Test Data for Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccount(Id businessInfoId){
        Account accountObj = new Account(Name = 'Alfred Hitchcock');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.Phone = '666714588';
        accountObj.BillingStreet = '2423 6th Avenue';
        accountObj.BillingCity = 'Frankenmouth';
        accountObj.BillingState = 'WA';
        accountObj.BillingPostalCode = '61232';
        return accountObj;
    }
    
    /**
    * @description Creating Test Data for Borrower Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrowerAccount(Id businessInfoId){
        clcommon__Legal_Entity__c borrowerEntity = new clcommon__Legal_Entity__c(Name = 'Trust');
        Database.insert(borrowerEntity);
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Quentin Tarantino';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.Phone = '666714588';
        borrowerAccountObj.Work_Number__c = '666714588';
        borrowerAccountObj.Home_Number__c = '666714588';
        borrowerAccountObj.BillingStreet = '2423 6th Avenue';
        borrowerAccountObj.BillingCity = 'Frankenmouth';
        borrowerAccountObj.BillingState = 'WA';
        borrowerAccountObj.BillingPostalCode = '61232';
        borrowerAccountObj.Billing_County__c = 'Michigan';
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = borrowerEntity.Id;
        Database.insert(borrowerAccountObj,false);
        return borrowerAccountObj;
    }
    /**
    * @description Create Business Account
    * @author  Pritam Roy | 02-23-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBusinessAccount(Id businessInfoId){
        Account accountObj = new Account(Name = 'Riley');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.Phone = '666714588';
        accountObj.BillingStreet = '2423 6th Avenue';
        accountObj.BillingCity = 'Frankenmouth';
        accountObj.BillingState = 'WA';
        accountObj.BillingPostalCode = '61232';
        return accountObj;
    }
    /**
    * @description Create Business Contact
    * @author  Pritam Roy | 02-23-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createBusinessContact(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Riley';
        contactObj.LastName = 'Nolan';
        contactObj.Phone = '9023784087';
        contactObj.genesis__SSN__c = '666714588';
        contactObj.ints__Middle_Name__c = 'P';
        contactObj.MailingStreet = '221 Baker Street';
        contactObj.MailingCity = 'Camden';
        contactObj.MailingState = 'WA';
        contactObj.MailingPostalCode = '61232';
        contactObj.Mailing_County__c = 'Michigan';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Business Information
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfo(){
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
		businessInfoObj.genesis__Tax_Identification_Number__c = '242424242';
        businessInfoObj.genesis__Total_Assets__c = 150000;
        businessInfoObj.genesis__Total_Liabilities__c = 50000;
        Database.insert(businessInfoObj);
        return businessInfoObj;
    } 
    /**
    * @description Creating Test Data for Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContact(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Christopher';
        contactObj.LastName = 'Nolan';
        contactObj.Phone = '9023784087';
        contactObj.genesis__SSN__c = '666714588';
        contactObj.ints__Middle_Name__c = 'P';
        contactObj.MailingStreet = '221 Baker Street';
        contactObj.MailingCity = 'Camden';
        contactObj.MailingState = 'WA';
        contactObj.MailingPostalCode = '61232';
        contactObj.Mailing_County__c = 'Michigan';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        Database.insert(contactObj);
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Second Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createSecondContact(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Wes';
        contactObj.LastName = 'Andersan';
        contactObj.Phone = '9023784087';
        contactObj.genesis__SSN__c = '666714589';
        contactObj.ints__Middle_Name__c = 'P';
        contactObj.MailingStreet = '221 Baker Street';
        contactObj.MailingCity = 'Camden';
        contactObj.MailingState = 'WA';
        contactObj.MailingPostalCode = '61232';
        contactObj.Mailing_County__c = 'Michigan';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        Database.insert(contactObj);
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplication(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 824001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Seeds');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }
    /**
    * @description Creating Test Data for Borrower Party
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationObj 
    * @param accountObj 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createBorrowerParty(genesis__Applications__c applicationObj, Account accountObj){
        
        clcommon__Party__c partyObj = new clcommon__Party__c();
        clcommon__Party_Type__c objPartyTypeBorrower = new clcommon__Party_Type__c(Name = 'BORROWER');
        Database.insert(objPartyTypeBorrower);
        partyObj.clcommon__Type__c = objPartyTypeBorrower.Id;
        partyObj.clcommon__Party_Types__c = 'BORROWER';
        partyObj.genesis__Application__c = applicationObj.Id;
        partyObj.clcommon__Account__c = accountObj.Id;
        partyObj.Mobile_Number__c = '666714588';
        partyObj.Work_Number__c = '666714588';
        partyObj.Home_Number__c = '666714588';
        partyObj.Street__c = '2423 6th Avenue';
        partyObj.City__c = 'Frankenmouth';
        partyObj.State__c = 'WA';
        partyObj.Postal_Code__c = '61232';
        partyObj.County__c = 'Michigan';
        return partyObj;
    }
    /**
    * @description Creating Data for Principal Party
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
        partyObj.Street__c = '1820 street';
        partyObj.City__c = 'Kolkata';
        partyObj.State__c = 'WA';
        partyObj.County__c='fghu';
        partyObj.Mobile_Number__c='098765678';
        return partyObj;
    }

    /**
    * @description Creating Test Data for Tier 1 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTier1(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '824001000';
        applicationObj.FICO_Score__c = '850';
        applicationObj.SBSS_70_Score__c = '250';
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Seeds');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 2 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTier2(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '8240010';
        applicationObj.FICO_Score__c = '700';
        applicationObj.SBSS_70_Score__c = '190';
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Seeds');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 3 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTier3(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '8240';
        applicationObj.FICO_Score__c = '600';
        applicationObj.SBSS_70_Score__c = '150';
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Seeds');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 4 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTier4(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '8240';
        applicationObj.FICO_Score__c = '100';
        applicationObj.SBSS_70_Score__c = '100';
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Seeds');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }


    /**
    * @description Creating Test data for the Credit Rating Matrix
    * @author Ayan Bhowmik | 02-21-2024 
    * @return List<genesis__Credit_Rating_Matrix__c> 
    **/
    public static List<genesis__Credit_Rating_Matrix__c> createCreditRatingMatrix(){
        List<genesis__Credit_Rating_Matrix__c> creditRatingList = new List<genesis__Credit_Rating_Matrix__c>();
        for(Integer countTier=1;countTier<=4;countTier++){
            
                genesis__Credit_Rating_Matrix__c objTier = new genesis__Credit_Rating_Matrix__c(Name='Tier '+countTier);
                creditRatingList.add(objTier);
            
        }
        Database.insert(creditRatingList);
        return creditRatingList;
        
    }

    /**
    * @description Creating Test data for Tier 1 application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrowerAccountforTier1(Id businessInfoId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Account Tier1';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.SBSS70_Score__c = '220';
        Database.insert(borrowerAccountObj,false);
        return borrowerAccountObj;
    }
    /**
    * @description Creating Test Data for Tier 1 Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccountforTier1(Id businessInfoId){
        Account accountObj = new Account(Name = 'PrincipalAcc Tier1');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.SBSS70_Score__c = '220';
        accountObj.Score_1__c = '750';
        Database.insert(accountObj);
        return accountObj;
    }
    /**
    * @description Creating Test Data for Tier 1 Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactForTier1(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'PrincipalContact';
        contactObj.LastName = 'Tier1';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        Database.insert(contactObj);
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Tier 1 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationWithTier1(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 10001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Power Driller');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }


    /**
    * @description Creating Test Data for Tier 2 Borrower Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrowerAccountforTier2(Id businessInfoId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Account Tier2';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.SBSS70_Score__c = '170';
        Database.insert(borrowerAccountObj,false);
        return borrowerAccountObj;
    }
    /**
    * @description Creating Test Data for Tier 2 Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccountforTier2(Id businessInfoId){
        Account accountObj = new Account(Name = 'PrincipalAcc Tier2');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.SBSS70_Score__c = '170';
        accountObj.Score_1__c = '680';
        Database.insert(accountObj);
        return accountObj;
    }
    /**
    * @description Creating Test Data for Tier 2 Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactForTier2(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'PrincipalContact';
        contactObj.LastName = 'Tier2';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        Database.insert(contactObj);
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Tier 2 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationWithTier2(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 50001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Tractor');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 3 Borrower Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrowerAccountforTier3(Id businessInfoId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Account Tier3';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.SBSS70_Score__c = '150';
        Database.insert(borrowerAccountObj,false);
        return borrowerAccountObj;
    }
    /**
    * @description Creating Test Data for Tier 3 Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccountforTier3(Id businessInfoId){
        Account accountObj = new Account(Name = 'PrincipalAcc Tier3');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.SBSS70_Score__c = '150';
        accountObj.Score_1__c = '620';
        Database.insert(accountObj);
        return accountObj;
    }
    /**
    * @description Creating Test Data for Tier 3 Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactForTier3(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'PrincipalContact';
        contactObj.LastName = 'Tier3';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        Database.insert(contactObj);
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Tier 3 Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationWithTier3(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 100001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Commercial Land');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }


    /**
    * @description Creating Test Data for Not Qualified Borrower Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrowerAccountforNotQualified(Id businessInfoId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Account NotQualified';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.SBSS70_Score__c = '100';
        Database.insert(borrowerAccountObj,false);
        return borrowerAccountObj;
    }
    /**
    * @description Creating Test Data for 
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccountforNotQualified(Id businessInfoId){
        Account accountObj = new Account(Name = 'PrincipalAcc NotQualified');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.SBSS70_Score__c = '100';
        accountObj.Score_1__c = '500';
        Database.insert(accountObj);
        return accountObj;
    }
    /**
    * @description Creating Test Data for Not Qualified Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactForNQ(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'PrincipalContact';
        contactObj.LastName = 'NotQualified';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        Database.insert(contactObj);
        return contactObj;
        
    }
    /**
    * @description Creating Test Data for Not Qualified Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationWithNQ(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 200001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Automatic Pump');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }

    //DATA FOR ERROR APPLICATION
    
    /**
    * @description Creating Test Data for Error Borrower Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrowerAccountforError(Id businessInfoId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Error Account';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.SBSS70_Score__c = '100';
        Database.insert(borrowerAccountObj,false);
        return borrowerAccountObj;
    }
    /**
    * @description Creating Test Data for Error Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationWithError(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 2001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Automatic Pump');
        insert newPurpose;
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        Database.insert(applicationObj);
        return applicationObj;
    }
    /**
    * @description Create Principal Contact
    * @author  Pritam Roy | 02-23-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createPrincipalContact(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Wes';
        contactObj.LastName = 'Andersan';
        contactObj.Phone = '9023784087';
        contactObj.genesis__SSN__c = '666714589';
        contactObj.ints__Middle_Name__c = 'P';
        contactObj.MailingStreet = '221 Baker Street';
        contactObj.MailingCity = 'Camden';
        contactObj.MailingState = 'WA';
        contactObj.MailingPostalCode = '61232';
        contactObj.Mailing_County__c = 'Michigan';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        return contactObj;
        
    }

    //Creating methods which return all records without inserting 
   
    /**
    * @description Creating Test Data for Business Information
    * @author Simran | 04-08-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForDealer(){
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
		businessInfoObj.genesis__Tax_Identification_Number__c = '689714588';
        businessInfoObj.genesis__Total_Assets__c = 150000;
        businessInfoObj.genesis__Total_Liabilities__c = 50000;
        return businessInfoObj;
    } 

    /**
    * @description Creting test data for credit rating matrix
    * @author Simran | 04-08-2024 
    * @return List<genesis__Credit_Rating_Matrix__c> 
    **/
    public static List<genesis__Credit_Rating_Matrix__c> createCredRatMatrix(){
        List<genesis__Credit_Rating_Matrix__c> creditRatingList = new List<genesis__Credit_Rating_Matrix__c>();
        for(Integer countTier=1;countTier<=4;countTier++){
            
                genesis__Credit_Rating_Matrix__c objTier = new genesis__Credit_Rating_Matrix__c(Name='Tier '+countTier);
                creditRatingList.add(objTier);
            
        }
        return creditRatingList;
        
    }

    /**
    * @description Test data for for tier 3 borrower account
    * @author Simran | 04-08-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBorrAccForTierIII(Id businessInfoId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Account Tier3';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.SBSS70_Score__c = '160';
        return borrowerAccountObj;
    }

    /**
    * @description Test data for tier 3 account
    * @author Simran | 04-08-2024 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createAccForTierIII(Id businessInfoId){
        Account accountObj = new Account(Name = 'PrincipalAcc Tier3');
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.SBSS70_Score__c = '150';
        accountObj.Score_1__c = '620';
        return accountObj;
    }

    /**
    * @description Test data for tier 3 contact
    * @author Simran | 04-08-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createConForTierIII(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'PrincipalContact';
        contactObj.LastName = 'Tier3';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        return contactObj;  
    }

    /**
    * @description Test data for tier 3 app
    * @author Simran | 04-08-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createAppWithTierIII(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 100001;
        clcommon__CL_Purpose__c  newPurpose = new clcommon__CL_Purpose__c (Name='Commercial Land');
        Database.insert(newPurpose,true);
        applicationObj.genesis__CL_Purpose__c = newPurpose.Id;
        return applicationObj;
    }

    
    /**
    * @description Test data for borrower type party
    * @author Simran | 04-08-2024 
    * @param applicationObj 
    * @param accountObj 
    * @param partyType 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createParty(genesis__Applications__c applicationObj, Account accountObj,clcommon__Party_Type__c partyType){
        
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Type__c = partyType.Id;
        partyObj.clcommon__Party_Types__c = 'BORROWER';
        partyObj.genesis__Application__c = applicationObj.Id;
        partyObj.clcommon__Account__c = accountObj.Id;
        return partyObj;
    }

    /**
    * @description Test data for party type
    * @author Simran | 04-08-2024 
    * @param partyTypeName 
    * @return clcommon__Party_Type__c 
    **/
    public static clcommon__Party_Type__c createPartytype(String partyTypeName){
        clcommon__Party_Type__c partyTypeobj = new clcommon__Party_Type__c();
        partyTypeobj.Name = partyTypeName;
        return partyTypeobj;
    }
    // New methods without inserting records in helper start here ----------------------------------------------------

    /**
    * @description Generic method to create legal entity
    * @author Ayan Bhowmik | 05-15-2024 
    * @param name 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createLegalEntity(String name){
        return new clcommon__Legal_Entity__c(Name = name, clcommon__Legal_Entity_Type__c = name);
    }
    /**
    * @description Creating Test Data for Borrower Account
    * @author Ayan Bhowmik | 05-15-2024 
    * @param businessInfoId 
    * @param legalEnityId 
    * @return Account 
    **/
    public static Account createBorrowerAccount(Id businessInfoId, Id legalEnityId){
        Account borrowerAccountObj = new Account();
        borrowerAccountObj.Name = 'Quentin Tarantino';
        borrowerAccountObj.genesis__Business_Information__c = businessInfoId;
        borrowerAccountObj.Phone = '666714588';
        borrowerAccountObj.Work_Number__c = '666714588';
        borrowerAccountObj.Home_Number__c = '666714588';
        borrowerAccountObj.BillingStreet = '2423 6th Avenue';
        borrowerAccountObj.BillingCity = 'Frankenmouth';
        borrowerAccountObj.BillingState = 'WA';
        borrowerAccountObj.BillingPostalCode = '61232';
        borrowerAccountObj.Billing_County__c = 'Michigan';
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEnityId;
        return borrowerAccountObj;
    }
    /**
    * @description Creating Test Data for Contact
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactForIndividual(Account accountObj){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Christopher';
        contactObj.LastName = 'Nolan';
        contactObj.Phone = '9023784087';
        contactObj.genesis__SSN__c = '666714588';
        contactObj.ints__Middle_Name__c = 'P';
        contactObj.MailingStreet = '221 Baker Street';
        contactObj.MailingCity = 'Camden';
        contactObj.MailingState = 'WA';
        contactObj.MailingPostalCode = '61232';
        contactObj.Mailing_County__c = 'Michigan';
        Date dob = Date.newInstance(1960, 2, 17);
        contactObj.Birthdate = dob;
        contactObj.AccountId = accountObj.Id;
        return contactObj;
    }
    /**
    * @description Generic method to create cl purpose
    * @author Ayan Bhowmik | 05-15-2024 
    * @param name 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurpose(String name){
        return new clcommon__CL_Purpose__c (Name = name);
    }
    /**
    * @description Creating Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @param applicationDataMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplication(Map<String, Object> applicationDataMap){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '398762543';
        applicationObj.Dealer_Name__c = (Id)applicationDataMap.get('dealerAccountObjId');
        applicationObj.genesis__CL_Product__c = (Id)applicationDataMap.get('clProductObjId');
        applicationObj.genesis__CL_Purpose__c = (Id)applicationDataMap.get('clPurposeObjId');
        applicationObj.genesis__Contact__c = (Id)applicationDataMap.get('borrowerContactObjId');
        applicationObj.genesis__Account__c = (Id)applicationDataMap.get('borrowerAccountObjId');
        applicationObj.Sales_Agent__c= (Id)applicationDataMap.get('saAccountObjId');
        applicationObj.Certified_Lender__c = (Id)applicationDataMap.get('clAccountObjId');
        return applicationObj;
    }
    /**
    * @description Creating Sole Prop Legal Entity
    * @author Ayan Bhowmik | 05-15-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createSolePropLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship';
        entityObj.Name = 'Individual(s) - Sole Proprietorship';
        return entityObj;
    }
    /**
    * @description Creating DBA Legal Entity
    * @author Ayan Bhowmik | 05-15-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createDBALegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Individual(s) with DBA';
        entityObj.Name = 'Individual(s) with DBA';
        return entityObj;
    }
    /**
    * @description Creating Corporation Legal Entity
    * @author Ayan Bhowmik | 05-15-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createCorporationLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        return entityObj;
    }
        /**
    * @description Creating Data for CL Product of Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLProductForApplication() {
        clcommon__CL_Product__c clProductObj = new clcommon__CL_Product__c();
        clProductObj.clcommon__Product_Name__c ='Simpli-Fi';
        return clProductObj;
    }
    /**
    * @description Creating data for Purpose of Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurposeForApplication() {
        clcommon__CL_Purpose__c  clPurposeObj = new clcommon__CL_Purpose__c();
        clPurposeObj.Name='Crop';
        return clPurposeObj;
    }
    /**
    * @description Creating Dealer Account With Coop Type CFA
    * @author Ayan Bhowmik | 05-15-2024 
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
        dealerAccountObj.BillingState = 'WA';
        dealerAccountObj.BillingPostalCode = '61232';
        dealerAccountObj.CIF_Number__c = '091284';
        dealerAccountObj.Coop_Type__c = 'CFA';
        dealerAccountObj.Tier__c = 'Gold';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Is_Required_ERP_Id__c = true;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        return dealerAccountObj;
    }
    /**
    * @description Creating Certfied Lender Account
    * @author Ayan Bhowmik | 05-15-2024 
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
        clAccountObj.BillingState = 'WA';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009988';
        clAccountObj.clcommon__Email__c = 'ross.geller@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Certified Lender').getRecordTypeId();
        return clAccountObj;
    }
    /**
    * @description Creating Sole Prop Borrower Account
    * @author Ayan Bhowmik | 05-15-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createSolePropAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Quentin Tarantino';
        accountObj.clcommon__Email__c='jasmin.albin@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingStreet = '1820 street';
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c='fghu';
        accountObj.BillingPostalCode='12345';
        accountObj.Work_Number__c='098765678';
        accountObj.Phone = '098765678';
        return accountObj;
    }
    /**
    * @description Creating Sole Prop Co-Borrower Account
    * @author Ayan Bhowmik | 05-15-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createCoBorrowerAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Christopher Nolan';
        accountObj.clcommon__Email__c = 'mike.johnson@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingStreet = '1820 street';
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c = 'fghu';
        accountObj.Work_Number__c = '098765678';
        accountObj.BillingPostalCode = '67374';
        accountObj.Phone = '098765678';
        return accountObj;
    }
    /**
    * @description Creating Business Information for Borrower
    * @author Ayan Bhowmik | 05-15-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForBorrower(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=100000;
        businessInfoObj.Contract_Loan_Limit__c=500000;
        businessInfoObj.Approved_Loan_Amount__c=200000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '666714588';
        businessInfoObj.genesis__Total_Liabilities__c=2346;
        businessInfoObj.genesis__Total_Assets__c=987683;
        return businessInfoObj;
    }
        /**
    * @description Creating Certified Lender Contact
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createCLContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Ross';
        clContactObj.LastName='Geller';
        clContactObj.genesis__SSN__c='555212313';
        clContactObj.Confirm_SSN__c='555212313';
        clContactObj.Email='ross.geller@yopmail.com';
        clContactObj.Phone='666714588';
        clContactObj.accountId = accountId;
        return clContactObj;
    }
        /**
    * @description Creating Borrower Contact
    * @author Ayan Bhowmik | 05-15-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createBorrowerContact(Id objAccountID){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Quentin';
        contactObj.LastName = 'Tarantino';
        contactObj.Email = 'jasmin.albin@yopmail.com';
        contactObj.Phone = '9734227544';
        contactObj.MobilePhone = '342134234';
        contactObj.genesis__SSN__c = 'GHFB6766';
        contactObj.accountId = objAccountId;
        contactObj.MailingCity = 'Kolkata';
        contactObj.MailingState = 'WA';
        contactObj.MailingStreet='nhgv';
        contactObj.Mailing_County__c = 'county';
        contactObj.MailingPostalCode = '12345';
        contactObj.Birthdate = System.today().addYears(-35);
        return contactObj;
    }
    /**
    * @description Creating Co-Borrower Contact
    * @author Ayan Bhowmik | 05-15-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createCoBorrowerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Christopher';
        contactObj.LastName='Nolan';
        contactObj.Email='mike.johnson@yopmail.com';
        contactObj.Phone='8638473943';
        contactObj.MobilePhone = '739438473';
        contactObj.genesis__SSN__c = '982983834';
        contactObj.accountId = objAccountId;
        contactObj.MailingCity = 'Mumbai';
        contactObj.MailingState = 'WA';
        contactObj.MailingStreet='Dombivali';
        contactObj.Mailing_County__c='county';
        contactObj.MailingPostalCode='67374';
        contactObj.Birthdate=System.today().addYears(-35);
        return contactObj;
    }
    
    /**
     * @description Generic Method For Creating Party 
     * @param paramMap 
     * @param accountObj 
     * @return  `clcommon__Party__c`
     */
    public static clcommon__Party__c createParty(Map<String, Id> paramMap, Account accountObj){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c=paramMap.get('accountId');
        partyObj.clcommon__Contact__c=paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        partyObj.Total_Assets__c = 2346;
        partyObj.Total_Liabilities__c = 2423433;
        partyObj.Mobile_Number__c = accountObj.Phone;
        partyObj.Street__c = accountObj.BillingStreet;
        partyObj.City__c = accountObj.BillingCity;
        partyObj.State__c = accountObj.BillingState;
        partyObj.Postal_Code__c = accountObj.BillingPostalCode;
        return partyObj;
    }
    /**
    * @description Creating Test Data for Tier 1 Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTierOne(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '824001000';
        applicationObj.FICO_Score__c = '850';
        applicationObj.SBSS_70_Score__c = '250';
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 2 Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTierTwo(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '8240010';
        applicationObj.FICO_Score__c = '700';
        applicationObj.SBSS_70_Score__c = '190';
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 3 Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTierThree(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '8240';
        applicationObj.FICO_Score__c = '600';
        applicationObj.SBSS_70_Score__c = '150';
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Tier 4 Application
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForTierFour(Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.Net_Worth__c = '8240';
        applicationObj.FICO_Score__c = '100';
        applicationObj.SBSS_70_Score__c = '100';
        return applicationObj;
    }

    /**
    * @description Get all tier applications
    * @author Ayan Bhowmik | 05-15-2024 
    * @param accountObj 
    * @param clPurposeObj 
    * @return Map<String, genesis__Applications__c> 
    **/
    public static Map<String, genesis__Applications__c> getAllTierApplications(Account accountObj, clcommon__CL_Purpose__c clPurposeObj){
        genesis__Applications__c tierOneApplicationObj = createApplicationForTierOne(accountObj);
        tierOneApplicationObj.genesis__CL_Purpose__c = clPurposeObj.Id;
        genesis__Applications__c tierTwoApplicationObj = createApplicationForTierTwo(accountObj);
        tierTwoApplicationObj.genesis__CL_Purpose__c = clPurposeObj.Id;
        genesis__Applications__c tierThreeApplicationObj = createApplicationForTierThree(accountObj);
        tierThreeApplicationObj.genesis__CL_Purpose__c = clPurposeObj.Id;
        genesis__Applications__c tierFourApplicationObj = createApplicationForTierFour(accountObj);
        tierFourApplicationObj.genesis__CL_Purpose__c = clPurposeObj.Id;

        return new Map<String, genesis__Applications__c>{'tierOneApplicationObj' => tierOneApplicationObj,
                                                            'tierTwoApplicationObj' => tierTwoApplicationObj,
                                                            'tierThreeApplicationObj' => tierThreeApplicationObj,
                                                            'tierFourApplicationObj' => tierFourApplicationObj};
    }


    /**
    * @description Creating Test data for the Credit Rating Matrix
    * @author Ayan Bhowmik | 05-15-2024 
    * @return List<genesis__Credit_Rating_Matrix__c> 
    **/
    public static List<genesis__Credit_Rating_Matrix__c> createAllCreditRatingMatrix(){
        List<genesis__Credit_Rating_Matrix__c> creditRatingList = new List<genesis__Credit_Rating_Matrix__c>();
        for(Integer countTier=1;countTier<=4;countTier++){
                genesis__Credit_Rating_Matrix__c objTier = new genesis__Credit_Rating_Matrix__c(Name='Tier '+countTier);
                creditRatingList.add(objTier);
        }
        return creditRatingList;
    }
    /**
    * @description Creating Certified Lender User
    * @author Ayan Bhowmik | 05-16-2024 
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
     * @description Creating a Dealer Applicant relationship record
     * @param applicantAccountId 
     * @param applicantContactId
     * @param dealerId  
     * @return  `Dealer_Applicant_Relationship__c`
     */
    public static Dealer_Applicant_Relationship__c createDealerApplicantRelationship(String applicantAccountId, String applicantContactId, String dealerId){
        Dealer_Applicant_Relationship__c dealerAppRelationObj = new Dealer_Applicant_Relationship__c();
        dealerAppRelationObj.Applicant__c = applicantAccountId;
        dealerAppRelationObj.Applicant_Contact__c = applicantContactId;
        dealerAppRelationObj.Dealer__c = dealerId;
        return dealerAppRelationObj;
    }
    /**
    * @description Fetching Certified Lender User
    * @author Ayan Bhowmik | 02-20-2024 
    * @param userName 
    * @return User 
    **/
    public static User getCLUser(String userName) {
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
    * @description Fetching Certified Lender User
    * @author Ayush Kumar Singh | 02-20-2024 
    * @param userName 
    * @return User 
    **/
    public static List<User> getCLUserList(String userName) {
        List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId IN (
                                        SELECT Id
                                            FROM Account
                                            WHERE Name = :userName)];
        if (userList.isEmpty()) {
            return null;
        }
        return userList;
    }
    /**
     * @description Fetching Admin user
     * @author Ayush Kumar Singh | 02-20-2024 
     * @return  `List<User>`
     */
    public static List<User> getAdminUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'System Administrator' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
     /**
     * @description Fetching Credit user
     * @author Ayush Kumar Singh | 02-20-2024 
     * @return  `List<User>`
     */
    public static List<User> getCreditUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'Credit' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
     /**
     * @description Fetching Mater Credit user
     * @author Ayan Bhowmik | 01-22-2025
     * @return  `List<User>`
     */
    public static List<User> getMasterCreditUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'Master Credit' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
     /**
     * @description Fetching Loan Accounting user
     * @author Ayan Bhowmik | 01-22-2025
     * @return  `List<User>`
     */
    public static List<User> getLoanAccountingUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'Loan Accounting' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
     /**
     * @description Fetching CFA Admin user
     * @author Ayan Bhowmik | 01-22-2025
     * @return  `List<User>`
     */
    public static List<User> getCFAAdminUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'CFA Admin User' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
}