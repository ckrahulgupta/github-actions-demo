/**
 * @description       : Test class for UpdateInvoiceDynamicJob
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class UpdateInvoiceDynamicJobTest {
    /**
    * @description - Create test data
    * @author Sk Minsar | 12-18-2024 
    **/
    @testSetup
	static void makeData() {
        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        Database.insert(floatingRateIndex, true);

        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('Test Partner Program',floatingRateIndex);
        Database.insert(partnerProgram, true);

        // create legal entity
		clcommon__Legal_Entity__c legalEntity = TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');

        // create business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c businessInfoObj = TestClassHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, businessInfoObj},true);

        // create dealer account
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.CFA_Partner_Program__c = partnerProgram.Id;
        Database.insert(dealerAccountObj,true);
                    
        // creating Accounts
        Account clUserAccount = TestClassHelper.createCLAccount(dealerBusinessInfoObj.id, dealerAccountObj.id);
        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(legalEntity,businessInfoObj.id); 
        Database.insert(new List<Account>{clUserAccount, borrowerAccountObj},true);

        //Create Contacts
        Contact clUserContact = TestClassHelper.createCLContact(clUserAccount.id);
        Contact borrowerContact = TestClassHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(new List<Contact>{clUserContact, borrowerContact}, true);

        User clUser = TestClassHelper.createCLUser(clUserContact.id);
        Database.insert(clUser, true);

        clcommon__Reciprocal_Role__c role  = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(role,true);

        clcommon__Relationship__c relationship = TestClassHelper.createCLDealerRelationship(role,dealerAccountObj.id,clUserAccount.id);
        Database.insert(relationship,true);

        clcommon__Bank_Account__c bankAccount = TestClassHelper.createBankAccount(dealerAccountObj.id);
        Database.insert(bankAccount,true);

        // create loan product
        clcommon__CL_Product__c clProductobj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductobj,true);

        clcommon__CL_Purpose__c clPurpose = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurpose,true);

        //Create application
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.id,
            'clProductId' => clProductobj.id,
            'clPurposeId' => clPurpose.id,
            'borrowerAccountId' => borrowerAccountObj.id,
            'borrowerContactId' => borrowerContact.id,
            'clAccountId' => clUserAccount.id
        });
        Database.insert(applicationObj,true);

        // Creating ACH funding transaction properties
        clcommon__Funding_Transactions_Properties__c achfundingPropertiesObj = LoanServicingTestHelper.createAchFundingTransactionProperties();
        Database.insert(achfundingPropertiesObj,true);

        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
         // Create ACH Payment Mode
         clcommon__Payment_Mode__c achPaymentModeObj = paymentModeMap.get('ACH');
         clcommon__Payment_Mode__c draftPaymentModeObj = paymentModeMap.get('DRAFT');
         clcommon__Payment_Mode__c paymentTypePaymentModeObj = paymentModeMap.get('PAYMENT');
 
         Database.insert(new List<clcommon__Payment_Mode__c>{
             draftPaymentModeObj,
             achPaymentModeObj,
             paymentTypePaymentModeObj
         },true);
         
        //Create invoice
        clcommon__Consolidated_Invoice__c achInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, achPaymentModeObj.Id);
        clcommon__Consolidated_Invoice__c draftInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, draftPaymentModeObj.Id);
        Database.insert(new List<clcommon__Consolidated_Invoice__c>{
            achInvoiceObj,
            draftInvoiceObj
        }, true);

        // Creating ACH funding transaction
        genesis__Funding_Transaction__c achfundingTransactionObj = LoanServicingTestHelper.createFundingTransaction(achPaymentModeObj.Id, achfundingPropertiesObj.Id, applicationObj.Id);
        achfundingTransactionObj.Pricing_Detail__c = achfundingTransactionObj.id;
        achfundingTransactionObj.invoice__c = achInvoiceObj.Id;
        Database.insert(achfundingTransactionObj,true);

        //Updating total amount in invoice
        achInvoiceObj.Total_Amount__c = achfundingTransactionObj.genesis__Amount__c;
        Database.update(achInvoiceObj, true);
    }

    /**
    * @description check for the case when we have a uer query in the dag configuration, so it should directly call the parameterized constructor instead of the deafault one.
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    static void testCheckForUserQuery(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.startTest();
        System.runAs(objAdmin){
            UpdateInvoiceDynamicJob obj=new UpdateInvoiceDynamicJob('MyDag','SELECT Id, genesis__Enabled_Flag__c, Status__c FROM genesis__Rate_Card_Setup_Header__c where genesis__End_Date__c= today');
            Id batchId=Database.executeBatch(obj,200);
            System.assertEquals(batchId!=null, true, 'Error in the DAG scheduling');
        }
        Test.stopTest();
    }

    /**
    * @description - check if the scheduler method of the dag is working or not.
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    static void testCheckDAGScheduler(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(objAdmin){

            String jobId = System.schedule('Schedule Update Invoice Batch' , '0 1 * * * ? *',  new UpdateInvoiceDynamicJob());
            UpdateInvoiceDynamicJob obj=new UpdateInvoiceDynamicJob();
            obj.doExecute(null);

            System.assertEquals(jobId!=null, true, 'Error in the DAG scheduling');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception is thrown when a null list is passed to the doExecute method for Invoice
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    static void checkEmptyInvoiceList(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        try{
            System.runAs(objAdmin){
                List<clcommon__Consolidated_Invoice__c> invoiceEmptyList=new List<clcommon__Consolidated_Invoice__c>();
                UpdateInvoiceDynamicJob obj=new UpdateInvoiceDynamicJob();
                obj.doExecute(null,invoiceEmptyList);
            }
        }
        catch(Exception e){
            System.assertEquals(e!=null, true, 'Exception not thrown');
            
        }
        Test.stopTest();
    }
}