/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class ApplicationOriginationSetupTestHelper {
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-23-2024 
    **/
    public static void createTestSetup(){
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

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = createLegalEntities();

        // Creating business info
        Map<String, genesis__Business_Information__c> businessInfoMap = ApplicationOriginationTestHelper.createMultipleBusinessInfo();
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            businessInfoMap.get('individualBusinessInfoObj'),
            businessInfoMap.get('corporationBusinessInfoObj'),
            businessInfoMap.get('dbaBusinessInfoObj')
        };
        Database.Insert(businessInfoList, true);

        Map<String, Account> dealerRelationAccountMap = createDealerRelationAccounts(dealerBusinessInfoObj.Id,newPartnerProgramObj.id );
        
        Map<String, Account> accountMap = ApplicationOriginationTestHelper.createDifferentGrowerAccounts(legalEntityMap, businessInfoMap, (dealerRelationAccountMap.get('dealer')).Id);
        Account coApplicantAccount = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityMap.get(PortalConstants.SOLE_PROP_ENTITY), businessInfoMap.get('individualBusinessInfoObj').id);
        coApplicantAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coApplicantAccount.ParentId = (dealerRelationAccountMap.get('dealer')).Id;

        List<Account> accountList = new List<Account>{
            coApplicantAccount,
            accountMap.get('solePropAccountObj'),
            accountMap.get('corporationAccountObj'),
            accountMap.get('dbaAccountObj')
        };
        Database.Insert(accountList, true);

        Map<String, Contact> dealerRelationcontactMap = createDealerRelationContacts(dealerRelationAccountMap,coApplicantAccount.Id,accountMap);

        Map<String, clcommon__Party_Type__c> partyTypeMap = ApplicationOriginationTestHelper.createMultiplePartyType();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c>{
            partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME),
            partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME),
            partyTypeMap.get(PortalConstants.CL_PARTY_NAME),
            partyTypeMap.get(PortalConstants.SALES_AGENT_PARTY_NAME)
        };
        Database.Insert(partyTypeList, true);

        Map<String, clcommon__Reciprocal_Role__c> rolesMap = createRoles();

        createRelationships(rolesMap,dealerRelationAccountMap);

        // Creating User
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(dealerRelationContactMap.get('clContact').Id);
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(dealerRelationContactMap.get('saContact').id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(dealerRelationContactMap.get('solePropContact').id);
        Database.insert(borrowerUserObj, true);
        List<User> usersList = new List<User>{
            clUserObj,
            saUserObj
        };
        Database.Insert(usersList, true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
                                                                                                        'dealerAccountObjId' => dealerRelationAccountMap.get('dealer').id,
                                                                                                        'clProductObjId' => clProductObj.id,
                                                                                                        'clPurposeObjId' => clPurposeObj.id,
                                                                                                        'borrowerAccountObjId' => accountMap.get('solePropAccountObj').Id,
                                                                                                        'borrowerContactObjId' => dealerRelationContactMap.get('solePropContact').id
                                                                                                    });
        applicationObj.Internal_Reference_Code__c = 'testApp001';
        applicationObj.genesis__Product_Type__c ='Package';
        Database.insert(applicationObj,true); 

        // List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                        'accountId' => accountMap.get('solePropAccountObj').Id,
                                                                                        'contactId' => dealerRelationContactMap.get('solePropContact').id,
                                                                                        'partyTypeId' => partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME).id,
                                                                                        'applicationId' => applicationObj.id
                                                                                    });
        // partyList.add(partyObj);
        partyObj.clcommon__Party_Types__c= PortalConstants.BORROWER_PARTY_NAME;
        partyObj=updatePartyDetails(new Map<String,Object>{ 'partyObj'=>partyObj,
                                                            'contactObj'=>dealerRelationContactMap.get('solePropContact'),
                                                            'dealerId'=>dealerRelationAccountMap.get('dealer').id,
                                                            'isCorp'=>false,
                                                            'applicationObj'=>applicationObj
                                                        });


        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => dealerRelationAccountMap.get('clAccount').id,
                                                                                            'contactId' => dealerRelationContactMap.get('clContact').id,
                                                                                            'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PARTY_NAME).id,
                                                                                            'applicationId' => applicationObj.id
                                                                                        });
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        // partyList.add(clPartyObj);


        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => coApplicantAccount.id,
                                                                                            'contactId' => dealerRelationContactMap.get('coApplicantContact').id,
                                                                                            'partyTypeId' => partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME).id,
                                                                                            'applicationId' => applicationObj.id
                                                                                        });
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        coPartyObj=updatePartyDetails(new Map<String,Object>{'partyObj'=>coPartyObj,
                                                             'contactObj'=>dealerRelationContactMap.get('coApplicantContact'),
                                                             'dealerId'=>dealerRelationAccountMap.get('dealer').id,
                                                             'isCorp'=>false
                                                        });


        // partyList.add(coPartyObj);

        genesis__Applications__c corpApplication = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
                                                                                                        'dealerAccountObjId' => dealerRelationAccountMap.get('dealer').id,
                                                                                                        'clProductObjId' => clProductObj.id,
                                                                                                        'clPurposeObjId' => clPurposeObj.id,
                                                                                                        'borrowerAccountObjId' => accountMap.get('corporationAccountObj').Id,
                                                                                                        'borrowerContactObjId' => dealerRelationContactMap.get('corporationContact').id
                                                                                                    });
        corpApplication.Internal_Reference_Code__c = 'testApp002';
        corpApplication.genesis__Product_Type__c ='Package';
        Database.insert(corpApplication,true); 

        clcommon__Party__c corpBorrowerParty = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                'accountId' => accountMap.get('corporationAccountObj').Id,
                                                                                                'contactId' => dealerRelationContactMap.get('corporationContact').id,
                                                                                                'partyTypeId' => partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME).id,
                                                                                                'applicationId' => corpApplication.id
                                                                                            });
        // partyList.add();
        corpBorrowerParty.clcommon__Party_Types__c= PortalConstants.BORROWER_PARTY_NAME;
        corpBorrowerParty=updatePartyDetails(new Map<String,Object>{'partyObj'=>corpBorrowerParty,
                                                                    'contactObj'=>dealerRelationContactMap.get('corporationContact'),
                                                                    'dealerId'=>dealerRelationAccountMap.get('dealer').id,
                                                                    'isCorp'=>true,
                                                                    'applicationObj'=>corpApplication
                                                                });

        clcommon__Party__c corpCLParty = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                        'accountId' => dealerRelationAccountMap.get('clAccount').id,
                                                                                        'contactId' => dealerRelationContactMap.get('clContact').id,
                                                                                        'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PARTY_NAME).id,
                                                                                        'applicationId' => corpApplication.id
                                                                                    });
        corpCLParty.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;

        clcommon__Party__c corpPrincipalParty = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                'accountId' => coApplicantAccount.id,
                                                                                                'contactId' => dealerRelationContactMap.get('coApplicantContact').id,
                                                                                                'partyTypeId' => partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME).id,
                                                                                                'applicationId' => corpApplication.id
                                                                                            });
        corpPrincipalParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        corpPrincipalParty=updatePartyDetails(new Map<String,Object>{'partyObj'=>corpPrincipalParty,
                                                                     'contactObj'=>dealerRelationContactMap.get('coApplicantContact'),
                                                                     'dealerId'=>dealerRelationAccountMap.get('dealer').id,
                                                                     'isCorp'=>false
                                                                });

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>{partyObj,clPartyObj,coPartyObj,corpBorrowerParty,corpCLParty,corpPrincipalParty};

        Database.insert(partyList, true);
    }

    /**
    * @description the purpose of this function is to create a dealer applicant relationship for the party and save it and fill the party details
    * @author Rakesh Saraf | 01-09-2025 
    * @param paramMap 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c updatePartyDetails(Map<String,Object> paramMap){
        clcommon__Party__c partyObj=(clcommon__Party__c) paramMap.get('partyObj');
        Contact partyContact=(Contact) paramMap.get('contactObj');
        Id dealerId=(Id)paramMap.get('dealerId');
        Boolean isCorporation=(Boolean)paramMap.get('isCorp');
        genesis__Applications__c applicationObj;

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(partyContact,dealerId);
        Database.insert(dealerApplicantRelObj,true);

        if(paramMap.containsKey('applicationObj')){
            applicationObj=(genesis__Applications__c)paramMap.get('applicationObj');
            applicationObj.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.id;
            Database.update(applicationObj,true);
        }

        if(isCorporation){
            partyObj=ApplicationOriginationTestHelper.insertCorporationPartyDetails(partyObj,dealerApplicantRelObj.id);
        }else{
            partyObj=ApplicationOriginationTestHelper.insertIndividualPartyDetails(partyObj,dealerApplicantRelObj.id);
        }

        return partyObj;
    }

    /**
    * @description : creates the necessary contacts
    * @author Krishanu Chinya | 09-04-2024 
    * @param dealerRelationAccountMap 
    * @param coApplicantAccountId 
    * @param accountMap 
    * @return Map<String, Contact> 
    **/
    private static Map<String,Contact> createDealerRelationContacts(Map<String, Account> dealerRelationAccountMap, Id coApplicantAccountId, Map<String,Account> accountMap){
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact((dealerRelationAccountMap.get('clAccount')).Id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(dealerRelationAccountMap.get('saAccount').id);
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(dealerRelationAccountMap.get('clPlusAccount').id);
        Contact iqContactObj = ApplicationOriginationTestHelper.createInquiryContact(dealerRelationAccountMap.get('iqAccount').id);
        Contact iqPlusContactObj = ApplicationOriginationTestHelper.createInquiryPlusContact(dealerRelationAccountMap.get('iqPlusAccount').id);

        Contact saPlusContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(dealerRelationAccountMap.get('saPlusAccount').id);
        Contact fsaContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(dealerRelationAccountMap.get('fsaAccount').id);
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(dealerRelationAccountMap.get('saaAccount').id);
        Contact paContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(dealerRelationAccountMap.get('paAccount').id);


        Contact coApplicantContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coApplicantAccountId);
        Contact solePropContactObj = ApplicationOriginationTestHelper.createBorrowerContact(accountMap.get('solePropAccountObj').Id);
        solePropContactObj.genesis__SSN__C = '982763493';
        Contact dbaContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('dbaAccountObj'));
        Contact corporationContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('corporationAccountObj'));
       
        List<Contact> contactList = new List<Contact>{
            clContactObj,
            saContactObj,
            clPlusContactObj,saPlusContactObj,fsaContactObj,saAdminContactObj,paContactObj,
            iqContactObj,
            iqPlusContactObj,
            coApplicantContactObj,
            solePropContactObj,
            dbaContactObj,
            corporationContactObj
        };
        Database.Insert(contactList, true);

        Map<String,Contact> dealerRelationContactMap = new Map<String, Contact>{
            'clContact' => clContactObj,
            'clPlusContact' => clPlusContactObj,
            'saContact' => saContactObj,
            'saPlusContact' => saPlusContactObj,
            'iqContact' => iqContactObj,
            'iqPlusContact' => iqPlusContactObj,
            'fsaContact' => fsaContactObj,
            'saaContact' => saAdminContactObj,
            'paContact' => paContactObj,
            'coApplicantContact' => coApplicantContactObj,
            'solePropContact' => solePropContactObj,
            'dbaContact' => dbaContactObj,
            'corporationContact' => corporationContactObj
        };
        return dealerRelationContactMap;
    }

    /**
    * @description : create necessary relationships
    * @author Krishanu Chinya | 09-03-2024 
    * @param rolesMap 
    * @param dealerRelationAccountMap 
    **/
    private static void createRelationships (Map<String, clcommon__Reciprocal_Role__c> rolesMap, Map<String, Account> dealerRelationAccountMap){
        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('clRole'), dealerRelationAccountMap.get('dealer').Id, dealerRelationAccountMap.get('clAccount').Id);
        clcommon__Relationship__c clPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('clPlusRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('clPlusAccount').id);
        clcommon__Relationship__c saRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('saRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('saAccount').id);
        clcommon__Relationship__c iqRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('inqRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('iqAccount').id);
        clcommon__Relationship__c iqPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('inqPlusRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('iqPlusAccount').id);
        clcommon__Relationship__c saPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('saPlusRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('saPlusAccount').id);
        clcommon__Relationship__c fsaRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('fsaRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('fsaAccount').id);
        clcommon__Relationship__c saAdminRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('saaRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('saaAccount').id);
        clcommon__Relationship__c paRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('paRole'),dealerRelationAccountMap.get('dealer').Id,dealerRelationAccountMap.get('paAccount').id);

        clcommon__Relationship__c saaRelationshipWithSa = ApplicationOriginationTestHelper.createCLDealerRelationship(rolesMap.get('rsaRole'),dealerRelationAccountMap.get('saaAccount').Id,dealerRelationAccountMap.get('saAccount').id);

        List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>{
            clRelationship,saRelationship,clPlusRelationship,iqRelationship,iqPlusRelationship,saPlusRelationship,fsaRelationship,saAdminRelationship,paRelationship,saaRelationshipWithSa
        };

        Database.Insert(relationshipList, true);
    }

    /**
    * @description : create necessary accounts 
    * @author Krishanu Chinya | 09-04-2024 
    * @param dealerBusinessInfoId 
    * @param partnerProgramId 
    * @return Map<String, Account> 
    **/
    private static Map<String, Account> createDealerRelationAccounts(Id dealerBusinessInfoId, Id partnerProgramId){
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoId,partnerProgramId);
        Database.Insert(dealerAccountObj, true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(null, dealerAccountObj.Id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account iqAccountObj = ApplicationOriginationTestHelper.createInquiryAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account iqPlusAccountObj = ApplicationOriginationTestHelper.createInquiryPlusAccount(dealerBusinessInfoId,dealerAccountObj.id);

        Account saPlusAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        saPlusAccountObj.Name = 'Martha James';
        saPlusAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent Plus').getRecordTypeId();

        Account fsaAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        fsaAccountObj.Name = 'Simon Leyland';
        fsaAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Field Staff Agent').getRecordTypeId();

        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        saAdminAccountObj.Name = 'Henry Yates';
        saAdminAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent Admin').getRecordTypeId();

        Account paAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        paAccountObj.Name = 'Lucy Hope';
        paAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment Administrator').getRecordTypeId();

        List<Account> accountList = new List<Account>{
            clAccountObj,saAccountObj,clPlusAccountObj,iqAccountObj,iqPlusAccountObj,saPlusAccountObj,fsaAccountObj,saAdminAccountObj,paAccountObj
        };
        Database.insert(accountList,true);

        Map<String, Account> dealerAccountMap = new Map<String, Account>{
            'dealer' => dealerAccountObj,
            'clAccount' => clAccountObj,
            'clPlusAccount' => clPlusAccountObj,
            'saAccount' => saAccountObj,
            'saPlusAccount' => saPlusAccountObj,
            'iqAccount' => iqAccountObj,
            'iqPlusAccount' => iqPlusAccountObj,
            'fsaAccount' => fsaAccountObj,
            'saaAccount' => saAdminAccountObj,
            'paAccount' => paAccountObj
        };
        return dealerAccountMap;
    }

    /**
    * @description : creating necessary roles 
    * @author Krishanu Chinya | 09-03-2024 
    * @return Map<String, clcommon__Reciprocal_Role__c> 
    **/
    private static Map<String, clcommon__Reciprocal_Role__c> createRoles(){
        Map<String, clcommon__Reciprocal_Role__c> rolesMap = ApplicationOriginationTestHelper.createDealerRoles();
        List<clcommon__Reciprocal_Role__c> rolesList = new List<clcommon__Reciprocal_Role__c>{
            rolesMap.get('clRole'),
            rolesMap.get('clPlusRole'),
            rolesMap.get('saRole'),
            rolesMap.get('saPlusRole'),
            rolesMap.get('inqRole'),
            rolesMap.get('inqPlusRole'),
            rolesMap.get('paRole'),
            rolesMap.get('fsaRole'),
            rolesMap.get('saaRole'),
            rolesMap.get('rsaRole')
        };
        Database.Insert(rolesList, true);
        return rolesMap;
    }

    /**
    * @description : creating necesasry legal entities
    * @author Krishanu Chinya | 09-03-2024 
    * @return Map<String, clcommon__Legal_Entity__c> 
    **/
    private static Map<String, clcommon__Legal_Entity__c> createLegalEntities(){
        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ApplicationOriginationTestHelper.createMultipleLegalEntity();
        List<clcommon__Legal_Entity__c> legalEntityList = new List<clcommon__Legal_Entity__c>{
            legalEntityMap.get(PortalConstants.INDIVIDUAL_ENTITY),
            legalEntityMap.get(PortalConstants.SOLE_PROP_ENTITY),
            legalEntityMap.get(PortalConstants.CORPORATION),
            legalEntityMap.get(PortalConstants.LIMITED_LIABILITY_COMPANY),
            legalEntityMap.get(PortalConstants.GENERAL_PARTNERSHIP),
            legalEntityMap.get(PortalConstants.LIMITED_PARTNERSHIP),
            legalEntityMap.get(PortalConstants.JOINT_VENTURE),
            legalEntityMap.get(PortalConstants.TRUST)
        };
        Database.Insert(legalEntityList, true);
        return legalEntityMap;
    }

    /**
    * @description creating principal party
    * @author Rakesh Saraf | 10-16-2024 
    * @param applicationObj 
    * @param entityObj 
    * @param existingApplicationObj 
    **/
    public static void createPrincipalParty(genesis__Applications__c applicationObj, clcommon__Legal_Entity__c entityObj, genesis__Applications__c existingApplicationObj){
        //creating business info for principal
        genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(principalBusinessInfoObj,true);
        // Creating CoApplicant Account
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);

        //Creating Co-Applicant contact
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
        coBorrowerContactObj.Confirm_SSN__c='982983834';
        Database.insert(coBorrowerContactObj,true);

        // Creating Principal party type
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(principalPartyTypeObj, true);

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(paramForPrincipalPartyMap);
        Database.insert(principalPartyObj,true);

        // Creating Principal Party for existing application
        Map<String,Id> existingAppParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingAppPartyObj = ApplicationOriginationTestHelper.createParty(existingAppParamMap);
        Database.insert(existingAppPartyObj,true);
    }

    /**
    * @description creating sales agent and sales agent admin account , contact , party
    * @author Rakesh Saraf | 10-16-2024 
    * @param dealerBusinessInfoObj 
    * @param dealerAccountObj 
    **/
    public static void createSaSaAdminTestData(genesis__Business_Information__c dealerBusinessInfoObj,Account dealerAccountObj){
        //creating Sales agent account
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAccountObj, true);

        // Creating Contact for Sales agent
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Database.insert(saContactObj,true);

        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        Database.insert(saUserObj, true);

        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        Database.insert(saPartyTypeObj, true);

        Map<String,Id> paramForSaPartyMap = new Map<String,Id>{
            'accountId' => saAccountObj.Id,
            'contactId' => saContactObj.Id,
            'partyTypeId' => saPartyTypeObj.Id,
            'applicationId' => null
        };

        clcommon__Party__c saPartyObj = ApplicationOriginationTestHelper.createParty(paramForSaPartyMap);
        Database.insert(saPartyObj, true);

        //creating a sales agent admin
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAdminAccObj, true);

        //createing sa admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);


        clcommon__Party_Type__c saAdminPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        Database.insert(saAdminPartyTypeObj, true);

        Map<String,Id> paramForSaAdminPartyMap = new Map<String,Id>{
            'accountId' => saAdminAccObj.Id,
            'contactId' => saAdminContactObj.Id,
            'partyTypeId' => saAdminPartyTypeObj.Id,
            'applicationId' => null
        };

        clcommon__Party__c saAdminPartyObj = ApplicationOriginationTestHelper.createParty(paramForSaAdminPartyMap);
        Database.insert(saAdminPartyObj, true);

        //creating related sales agent  role
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        Database.insert(rsaRoleObj, true);

        //creating related sales agent  relationship
        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccountObj.Id);
        Database.insert(relationshipObject, true);
    }

    /**
    * @description creating additional test data
    * @author Rakesh Saraf | 10-16-2024 
    * @param applicationObj 
    * @param dealerAccountObj 
    **/
    public static void createAdditionalTestData(genesis__Applications__c applicationObj, Account dealerAccountObj){
        clcommon__document_category__c docCategory = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id,'liscense');
        Database.insert(docCategory,true);
   
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);
   
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        Database.insert(rateCardHeaderObj,true);
        genesis__Rate_Card_Setup_Detail__c arateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        arateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        Database.insert(arateCardSetupDetails,true);
   
        genesis__Application_Pricing_Detail__c pricingDetail = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj,arateCardSetupDetails.Id);
        Database.insert(pricingDetail,true);
   
        List<Task> taskObjList = new List<Task>();
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Customized Loan Approval'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Assignment of Insurance'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Notice of Security Interest (CFA Action)'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Additional Information Form'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Entity Documents'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Spousal Consent'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Notice of Security Interest'));
        taskObjList.add(ApplicationOriginationTestHelper.createTask(applicationObj.Id,'Withdrawal Form'));
        Database.insert(taskObjList,true);
   
        clcommon__Collateral_Category__c collateralCategoryObj = ApplicationOriginationTestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);
   
        Map<String,String> collateralDetailsMap = new Map<String,String>{
            'collateralCategoryId' => collateralCategoryObj.Id,
            'insurancePlan' => 'RP',
            'percentCoverageLevel' => '85%',
            'collateralName'=>'Oats',
            'totalAcres'=>'100',
            'producerShare'=>'100',
            'approvedYield'=>'100',
            'percentFed'=>'0',
            'price'=>'100'
        };
   
        clcommon__collateral__c collateralObj = ApplicationOriginationTestHelper.createCollateral(collateralDetailsMap);
        collateralObj.genesis__Application__c = applicationObj.Id;
        Database.insert(collateralObj,true);

    }

    /**
    * @description creating party of Additional Info
    * @author Rakesh Saraf | 10-16-2024 
    * @param applicationObj 
    * @param entityObj 
    * @param businessInfo 
    **/
    public static void createAdditionalInfoParty(genesis__Applications__c applicationObj, clcommon__Legal_Entity__c entityObj, genesis__Business_Information__c businessInfo){
        List<clcommon__Party__c> addInfoPartyObjList = new List<clcommon__Party__c>();

        Account buyerAccountObj = ApplicationOriginationTestHelper.createBuyerAccount(entityObj, businessInfo.Id);
        Account loAccountObj = ApplicationOriginationTestHelper.createLandOwnerAccount(entityObj,businessInfo.Id);
        Account iaAccountObj = ApplicationOriginationTestHelper.createInsuranceAgentAccount(entityObj,businessInfo.Id);
        Account spAccountObj = ApplicationOriginationTestHelper.createAccount();
        spAccountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        spAccountObj.genesis__Business_Information__c = businessInfo.Id;

        Database.insert(new List<Account>{
            buyerAccountObj,
            loAccountObj,
            iaAccountObj,
            spAccountObj
        }, true);

        Contact buyerContactObj = ApplicationOriginationTestHelper.createBuyerContact(buyerAccountObj.Id);
        Contact loContactObj = ApplicationOriginationTestHelper.createLandOwnerContact(loAccountObj.Id);
        Contact iaContactObj = ApplicationOriginationTestHelper.createInsuranceAgentContact(iaAccountObj.Id);
        Contact spContactObj = ApplicationOriginationTestHelper.createContact();
        spContactObj.accountId = spAccountObj.Id;

        Database.insert(new List<Contact>{
            buyerContactObj,
            loContactObj,
            iaContactObj,
            spContactObj
        }, true);

        clcommon__Party_Type__c spPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SPOUSE');
        clcommon__Party_Type__c loPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('LANDOWNER');
        clcommon__Party_Type__c iaPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('INSURANCE AGENT');
        clcommon__Party_Type__c buPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BUYER');

        Database.insert(new List<clcommon__Party_Type__c>{
            spPartyTypeObj,
            loPartyTypeObj,
            iaPartyTypeObj,
            buPartyTypeObj
        }, true);

        Map<String,Id> paramForSpPartyMap = new Map<String,Id>{
            'accountId' => spAccountObj.Id,
            'contactId' => spContactObj.Id,
            'partyTypeId' => spPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ApplicationOriginationTestHelper.createParty(paramForSpPartyMap));

        Map<String,Id> paramForLoPartyMap = new Map<String,Id>{
            'accountId' => loAccountObj.Id,
            'contactId' => loContactObj.Id,
            'partyTypeId' => loPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ApplicationOriginationTestHelper.createParty(paramForLoPartyMap));

        Map<String,Id> paramForIAPartyMap = new Map<String,Id>{
            'accountId' => iaAccountObj.Id,
            'contactId' => iaContactObj.Id,
            'partyTypeId' => iaPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ApplicationOriginationTestHelper.createParty(paramForIAPartyMap));

        Map<String,Id> paramForBuPartyMap = new Map<String,Id>{
            'accountId' => buyerAccountObj.Id,
            'contactId' => buyerContactObj.Id,
            'partyTypeId' => buPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ApplicationOriginationTestHelper.createParty(paramForBuPartyMap));
        Database.insert(addInfoPartyObjList,true);

    }
    /**
    * @description : Method to create Submission API test data.
    * @author Suraj Kumar | 01-17-2025 
    **/
    public static void createSubmissionAPITestData(){
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        // clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj), true);

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj,principalBusinessInfoObj,borrowerBusinessInfoObj}, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,principalPartyTypeObj,clPartyTypeObj}, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.BillingStreet = 'Action area 1';
        borrowerAccountObj.BillingPostalCode = '10038';
        borrowerAccountObj.Phone = '1111111111';

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccountObj.BillingStreet = 'Action area 1';
        coBorrowerAccountObj.BillingPostalCode = '10038';
        coBorrowerAccountObj.Phone = '1111111111';

        Account anotherSaAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        anotherSaAccountObj.Name = 'Marcus SA';
        Database.insert(new List<Account> {clAccountObj,borrowerAccountObj,coBorrowerAccountObj,anotherSaAccountObj}, true);
        

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.Confirm_SSN__c = 'GHFB6766';
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
        coBorrowerContactObj.Confirm_SSN__c='982983834';
        coBorrowerContactObj.clcommon__Marital_Status__c = 'Married';

        Contact anotherSaContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(anotherSaAccountObj.Id);
        anotherSaContactObj.firstName = 'Marcus';
        anotherSaContactObj.LastName = 'SA';
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,coBorrowerContactObj,anotherSaContactObj},true);

        // List<User> userObjList = new List<User>();
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User anotherSaUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(anotherSaContactObj.Id);
        anotherSaUserObj.Username = 'marcus.sa@yopmail.com';
        Database.insert(new List<User>{clUserObj,anotherSaUserObj},true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);
        
        // Creating dealer applicant relationship for borrower and principal
        Dealer_Applicant_Relationship__c dealerApplicantRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c dealerCoAppRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerCoAppRelObj,dealerApplicantRelObj},true);

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
        applicationObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.Id;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.OwnerId = clUserObj.Id;
        applicationObj.genesis__Expected_Start_Date__c=System.today();

        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        existingApplicationObj.genesis__Loan_Number__c = '116623344';
        existingApplicationObj.Signing_Method__c = 'Paper - Scanned';
        existingApplicationObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.Id;

        Database.insert(new List<genesis__Applications__c>{applicationObj,existingApplicationObj}, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        Database.insert(ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id), true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);

        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__party__c borrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj);
        borrowerParty.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;

        // Creating Principal Party for existing application
        Map<String,Id> paramForExistingBorrower = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingBorrPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForExistingBorrower,borrowerAccountObj);
        existingBorrPartyObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;

        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForPrincipalPartyMap,coBorrowerAccountObj);
        principalPartyObj.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;

        // Creating Principal Party for existing application
        Map<String,Id> existingCoAppParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingCoAppPartyObj = ApplicationOriginationTestHelper.createApplicantParty(existingCoAppParamMap,coBorrowerAccountObj);
        existingCoAppPartyObj.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;
        Database.insert(new List<clcommon__Party__c>{borrowerParty,existingBorrPartyObj,principalPartyObj,existingCoAppPartyObj,ApplicationOriginationTestHelper.createParty(paramForCLPartyMap)},true);

        genesis__Rate_Card_Setup_Header__c anotherRateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        anotherRateCardHeaderObj.Name = 'My Program Test 2';
        Database.insert(anotherRateCardHeaderObj,true);
        genesis__Rate_Card_Setup_Detail__c arateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(anotherRateCardHeaderObj);
        arateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        Database.insert(arateCardSetupDetails,true);
    }
}