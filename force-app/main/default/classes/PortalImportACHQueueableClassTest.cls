/**
 * @description       : Test class for PortalImportACHQueueableClass
 * @author            : Simran
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : Sk Minsar
**/

@isTest
public without sharing class PortalImportACHQueueableClassTest {
    
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 12-17-2024 
    **/
    @testSetup
    static void setup() {
        clcommon__Payment_Mode__c achPaymentMode = LoanServicingTestHelper.createPaymentMode('ACH');
        Database.insert(achPaymentMode, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = LoanServicingTestHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj, true);

        // Creating Account 
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(entityObj, LoanServicingTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(new List<Account>{borrowerAccountObj, clAccountObj}, true);

        // Creating Contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj},true);

        //Create user
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{borrowerUserObj, clUserObj}, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        genesis__Applications__c currApplicationObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String, Id>{
                                                        'dealerAccountId' => dealerAccountObj.Id,
                                                        'clProductId' => clProductObj.Id,
                                                        'clPurposeId' => clPurposeObj.Id,
                                                        'borrowerAccountId' => borrowerAccountObj.Id,
                                                        'borrowerContactId' => borrowerContactObj.Id,
                                                        'clAccountId' => clAccountObj.Id
        });
        Database.insert(currApplicationObj,true);

        genesis__Application_Pricing_Detail__c newPricingDetails = LoanServicingTestHelper.createPricingDetail(currApplicationObj.Id);
        genesis__Application_Pricing_Detail__c secondPricingDetails = LoanServicingTestHelper.createPricingDetail(currApplicationObj.Id);
        newPricingDetails.Loan_Number__c = '123234345-A';
        newPricingDetails.Loan_Number__c = '123234345-B';
        Database.insert(new List<genesis__Application_Pricing_Detail__c>{newPricingDetails, secondPricingDetails},true);

        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj, clPartyTypeObj}, true);

        // Creating Party
        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(new Map<String,Id>{
                                    'accountId' => clAccountObj.Id,
                                    'contactId' => clContactObj.Id,
                                    'partyTypeId' => clPartyTypeObj.Id,
                                    'applicationId' => currApplicationObj.Id
        });
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => currApplicationObj.Id
        });
        Database.insert(new List<clcommon__Party__c>{clPartyObj, borrowerPartyObj}, true);

        //creating content version
        ContentVersion contentObj= LoanServicingTestHelper.createContentVersion('Test ACH');
        contentObj.Title = 'Test ACH';
        contentObj.PathOnClient='/'+contentObj.Title+'.pdf';
        Database.insert(contentObj,true);

        //creating content Document
        ContentDocument contentACHObj = [SELECT Id FROM ContentDocument WHERE Title = 'Test ACH' LIMIT 1];

        //creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentACHObj.Id,currApplicationObj.Id);
        Database.insert(contentDocLinkAgrmttObj,true);
    }

    /**
    * @description - This method is used to set the request params
    * @author Sk Minsar | 12-17-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getParamMap(){
        User objCertifiedLenderUser = [SELECT Id, Name, AccountId, Account.ParentId, ContactId FROM User WHERE UserName='ross.geller@yopmail.com'];
        genesis__Applications__c objApplication =[Select Id,genesis__Account__c  FROM genesis__Applications__c WHERE Loan_Id__c = '139000'];
        genesis__Application_Pricing_Detail__c pricingDetails=[SELECT Id, Name,genesis__Enabled_Flag__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c=:objApplication.Id AND Loan_Number__c = '123234345-A'];
       return new Map<String, Object>{
           'objCertifiedLenderUser' => objCertifiedLenderUser,
           'objApplication' => objApplication,
           'pricingDetails' => pricingDetails
       };
   }
    
    /**
    * @description - Test with importing Multiple ACH transaction
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void  testACHQueableSuccess() {
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('123234345-A');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'123234345-A','Test A, Test B', '10'},
            new List<String>{'123234345-A','Test A, Test B', '10'},
            new List<String>{'123234345-A','Test A, Test B', '30'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];
        Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '20'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };                              
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList, achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()>0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description - Test with importing single ACH transaction
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void  testACHQueableSingleTrxSuccess() {
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('123234345-A');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'123234345-A','Test A, Test B', '10'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];
        Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '10'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };                              
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList, achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()>0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
        
    }

    /**
    * @description - Test with importing single ACH transaction
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void  testACHQueableMultiTrancheTrxSuccess() {
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('123234345-A');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'123234345-A','Test A, Test B', '10'},
            new List<String>{'123234345-B','Test A, Test B', '10'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];
        Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '20'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };                              
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList, achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()>0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
        
    }

    /**
    * @description - Method to check application details Exception
    * @author Simran | 08-30-2024 
    **/
    @isTest
    public static void testAppDetailsException() {
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        objApplication.genesis__Status__c='NEW-ENTERED';
        Database.update(objApplication,true); 
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('123234345-A');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'123234345-A','Test A, Test B', '10'},
            new List<String>{'123234345-A','Test A, Test B', '10'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];
         Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '20'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };
        
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList,achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()==0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description - Method to check application status Exception
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void  testAppStatuseException() {
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        objApplication.genesis__Status__c='NEW-ENTERED';
        Database.update(objApplication,true); 
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('123234345-A');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'123234345-A','Test A, Test B', '10'},
            new List<String>{'123234345-A','Test A, Test B', '10'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];

        Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '20'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList,achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()==0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
        
    }
    
    /**
    * @description -  Method to check Pricing details Exception
    * @author Simran | 08-30-2024 
    **/
    @isTest
    public static void  testPricingDetailsException() {
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        genesis__Application_Pricing_Detail__c pricingDetails=(genesis__Application_Pricing_Detail__c)paramMap.get('pricingDetails');
        pricingDetails.genesis__Enabled_Flag__c =false;
        Database.update(pricingDetails,true);
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('123234345-A');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'123234345-A','Test A, Test B', '10'},
            new List<String>{'123234345-A','Test A, Test B', '10'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];
        Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '20'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };

        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList,achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()==0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
        
    }
    
    /**
    * @description - Method to check Custom Exception
    * @author Simran | 08-30-2024 
    **/
    @isTest
    public static void testACHQueueableCustomExecption(){
        Map<String, Object> paramMap = getParamMap();
        User objCertifiedLenderUser = (User)paramMap.get('objCertifiedLenderUser');
        genesis__Applications__c objApplication =(genesis__Applications__c)paramMap.get('objApplication');
        Set<String> uniqueLoan=new Set<String>();
        uniqueLoan.add('343219520');
        List<List<String>> allCSVFileLinesList = new List<List<String>>{
            new List<String>{'343219520-A','Test A, Test B', '10'}
        };
        clcommon__Payment_Mode__c objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name = 'ACH'
                              LIMIT 1];
        Map<String, Object> achParamMap = new Map<String, Object>{
            PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoan,
            PortalConstants.KEY_LOAN_DETAILS_MAP => new Map<String, Map<String, String>>{
                '123234345' => new Map<String, String>{
                    PortalConstants.APPLICATION_ID_KEY => objApplication.Id,
                    PortalConstants.KEY_AMOUNT => '20'
                }
            },
            PortalConstants.KEY_PAYMENT_MODE => objPaymentMode
        };                                
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList,achParamMap));
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()==0, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
    }
}