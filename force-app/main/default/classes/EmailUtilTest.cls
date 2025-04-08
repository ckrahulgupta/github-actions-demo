/**
 * @description       : testclass for emailUtil
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-09-2025
 * @last modified by  : Rakesh Saraf
**/
@IsTest
public class EmailUtilTest {
    /**
    * @description : creating test data
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @TestSetup
    static void setup() {
        // Creating floating rate index
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

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
    
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.id);
        dealerAccountObj.CIF_Number__c = '314314';
        Database.insert(dealerAccountObj, true);
    
        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);
    }

    /**
    * @description : testing the getEmailTemplateMethod
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @isTest
    static void testGetEmailTemplate() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test action invocation
        System.runAs(adminUser) {
            Test.startTest();
            EmailTemplate emailTemplate = EmailUtil.getEmailTemplate('Email Change Alert');
            Test.stopTest();
            System.assertEquals('Email Change Request Received', emailTemplate.Subject, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : testing the getEmailTemplate method for exception scenario
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @isTest
    static void testGetEmailTemplateFailure() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test action invocation
        System.runAs(adminUser) {
            Test.startTest();
            try{
                EmailTemplate emailTemplate = EmailUtil.getEmailTemplate('NewEmailTemplate');
                emailTemplate.subject = 'Test subject';
            }catch (Exception e) {
                System.assertEquals('Something went wrong', e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description : testing the getOrgWideEmailAddress Method
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @isTest
    static void testGetOrgWideEmailAddress() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(adminUser) {
            Test.startTest();
            // Call the getOrgWideEmailAddress method
            List<OrgWideEmailAddress> orgWideEmailList = EmailUtil.getOrgWideEmailAddress('FIELD FINANCE');
            Test.stopTest();

            // Verify that the correct org wide email address is returned
            System.assertEquals(1, orgWideEmailList.size(), PortalConstants.ASSERTION_FAILED);
            System.assertEquals('FIELD FINANCE', orgWideEmailList[0].DisplayName, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : testing the getLogoByUrl method
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @isTest
    static void testGetLogoURLbyCoopType() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(adminUser) {
            Test.startTest();

            // Call the getLogoURLbyCoopType method with different coop types
            String gmkLogoUrl = EmailUtil.getLogoURLbyCoopType(ConstantValues.GROWMARK_COOP_TYPE);
            String landusLogoUrl = EmailUtil.getLogoURLbyCoopType(ConstantValues.LANDUS_COOP_TYPE);
            String cfaLogoUrl = EmailUtil.getLogoURLbyCoopType('Other');
            Test.stopTest();


            // Verify that the correct logo URLs are returned
            System.assertEquals(System.Label.GMK_Logo_Url, gmkLogoUrl, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(System.Label.Landus_Logo_Url, landusLogoUrl, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(System.Label.CFA_Logo_Url, cfaLogoUrl, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : testing  the getContactInfo api
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @isTest
    static void testGetContactInfoByCoop() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(adminUser) {
            Test.startTest();

            // Call the getContactInfoByCoop method with different coop types
            String gmkContactInfo = EmailUtil.getContactInfoByCoop(PortalConstants.GROWMARK_COOP_TYPE);
            String cfaContactInfo = EmailUtil.getContactInfoByCoop('Other');
            Test.stopTest();


            // Verify that the correct contact information is returned
            System.assertEquals(System.Label.GMK_Contact_Information, gmkContactInfo, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(System.Label.CFA_Contact_Information, cfaContactInfo, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : testing to fetch the color respective to different coop
    * @author Krishanu Chinya | 04-15-2024 
    **/
    @isTest
    static void testGetColorByCoop() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(adminUser) {
            Test.startTest();

            // Call the getColorByCoop method with different coop types
            String gmkColor = EmailUtil.getColorByCoop(PortalConstants.GROWMARK_COOP_TYPE);
            String landusColor = EmailUtil.getColorByCoop(PortalConstants.LANDUS_COOP_TYPE);
            String cfaColor = EmailUtil.getColorByCoop('Other');
            Test.stopTest();

            // Verify that the correct color codes are returned
            System.assertEquals(System.Label.Growmark_Primary_Color, gmkColor, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(System.Label.Landus_Primary_Color, landusColor, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(System.Label.CFA_Primary_Color, cfaColor, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : test save email Log 
    * @author Suraj Kumar | 05-03-2024 
    **/
    @isTest
    static void testGetEmailLog() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>{
            'fromAddress' => 'testsender@yopmail.com',
            'toAddress' => 'testreceiver@yopmail.com',
            'emailtemplateForLog' => 'testgroweremailtemplate',
            'messageLog' => 'testemailbody',
            'className' => 'EmailUtilTest',
            'emailStatus' => 'Success'
        };
        System.runAs(adminUser) {
            Test.startTest();

            // calling the method
            clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(requestMap);
            Test.stopTest();
            System.assertEquals('EmailUtilTest', notificationObj.Class_Name__c , 'Assertion failed');
            System.assertEquals('Success', notificationObj.Email_Status__c , 'Assertion failed');
            System.assertEquals('testgroweremailtemplate', notificationObj.Email_Template__c , 'Assertion failed');
            System.assertEquals('testreceiver@yopmail.com', notificationObj.Recipient_Address__c , 'Assertion failed');
            System.assertEquals('testemailbody', notificationObj.Email_Body__c , 'Assertion failed');
            System.assertEquals('testsender@yopmail.com', notificationObj.clcommon__Email_Address__c , 'Assertion failed');
            
        }
    }

    /**
    * @description : test save email Log for null parameter
    * @author Suraj Kumar | 05-03-2024 
    **/
    @isTest
    static void testGetEmailLogForNullKey() {
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>();
        System.runAs(adminUser) {
            Test.startTest();
            // calling the method
            clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(requestMap);
            Test.stopTest();
            System.assertEquals(null, notificationObj , 'Assertion failed');
        }
    }

    /**
    * @description : method to test saveUnsentEmailLog 
    * @author Suraj Kumar | 05-06-2024 
    **/
    @isTest
    static void testGetUnsentEmailLog(){
        User adminUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(adminUser) {
            Test.startTest();
            // calling the method
            clcommon__Log__c logObj = EmailUtil.getUnsentEmailLog('Loan Booked Notification For Grower', 'Recipient email missing');
            Test.stopTest();
            System.assertEquals('Loan Booked Notification For Grower', logObj.Name , 'Assertion failed');
        }
    }

    /**
    * @description test for setting logo url in the email for gmk user
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testSetLogoURLForGMK(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'Growmark';
        dealerAcc.CFA_Partner_Program__c = null;
        Database.update(dealerAcc, true);
        
        System.runAs(adminUser) {
            Test.startTest();
                String gmkLogoURL = EmailUtil.setLogoURL(dealerAcc.id);
            Test.stopTest();

            System.assertEquals(System.Label.GMK_Logo_Url, gmkLogoURL, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description the purpose of this method is to get the exception if there is not partner program for the dealer to get the logo from
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testSetLogoURLForNull(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'CFA';
        dealerAcc.CFA_Partner_Program__c = null;
        Database.update(dealerAcc, true);

        System.runAs(adminUser) {
            Test.startTest();
            try{
                EmailUtil.setLogoURL(dealerAcc.id);
                
            }catch (Exception e) {
                System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }

    }

    /**
    * @description test for the scenario when there is no logo in the pertner program
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testSetLogoURLForNoLogo(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c, CFA_Partner_Program__c, CFA_Partner_Program__r.Dealer_Portal_Logo__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'CFA';
        Database.update(dealerAcc, true);
        CFA_Partner_Program__c partnerProgram = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAcc.CFA_Partner_Program__c];
        partnerProgram.Dealer_Portal_Logo__c = null;
        Database.update(partnerProgram, true);
        
        System.runAs(adminUser) {
            Test.startTest();
                String  cfaLogoURL= EmailUtil.setLogoURL(dealerAcc.id);
            Test.stopTest();

            System.assertEquals(ConstantValues.EMPTY_STRING, cfaLogoURL, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description test to get the logo for a cfa user
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testSetLogoURLForCFALogo(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c, CFA_Partner_Program__c, CFA_Partner_Program__r.Dealer_Portal_Logo__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'CFA';
        Database.update(dealerAcc, true);
        CFA_Partner_Program__c partnerProgram = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAcc.CFA_Partner_Program__c];
        partnerProgram.Dealer_Portal_Logo__c = 'cfaLogo';
        Database.update(partnerProgram, true);
        
        System.runAs(adminUser) {
            Test.startTest();
                String  cfaLogoURL= EmailUtil.setLogoURL(dealerAcc.id);
            Test.stopTest();

            System.assertEquals(ConstantValues.LOGO_BASE_URL + 'cfaLogo', cfaLogoURL, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description et the contact info for a gmk contact
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void setContactInfoForGMK(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'Growmark';
        dealerAcc.CFA_Partner_Program__c = null;
        Database.update(dealerAcc, true);
        
        System.runAs(adminUser) {
            Test.startTest();
                String gmkMobileNumber = EmailUtil.setContactInfo(dealerAcc.id);
            Test.stopTest();

            System.assertEquals(System.Label.GMK_Contact_Information, gmkMobileNumber, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description catch the exception thrown when there is no partner program for the dealer to get the number from
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void setContactInfoForNull(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'CFA';
        dealerAcc.CFA_Partner_Program__c = null;
        Database.update(dealerAcc, true);

        System.runAs(adminUser) {
            Test.startTest();
            try{
                EmailUtil.setContactInfo(dealerAcc.id);
                
            }catch (Exception e) {
                System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }

    }

    /**
    * @description throw exception when the partner program does not have a number
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void setContactInfoForNoNumber(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c, CFA_Partner_Program__c, CFA_Partner_Program__r.Dealer_Portal_Logo__c FROM Account WHERE CIF_Number__c = '314314'];
        dealerAcc.Coop_Type__c = 'CFA';
        Database.update(dealerAcc, true);
        CFA_Partner_Program__c partnerProgram = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAcc.CFA_Partner_Program__c];
        partnerProgram.Mobile__c = null;
        Database.update(partnerProgram, true);
        
        System.runAs(adminUser) {
            Test.startTest();
            try{
                EmailUtil.setContactInfo(dealerAcc.id);
                
            }catch (Exception e) {
                System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }

    }

    /**
    * @description test method for getting the number from cfa partner program
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void setContactInfoForCFAContactInfo(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c, CFA_Partner_Program__c, CFA_Partner_Program__r.Dealer_Portal_Logo__c FROM Account WHERE CIF_Number__c = '314314'];                                                                                      
        dealerAcc.Coop_Type__c = 'CFA';
        Database.update(dealerAcc, true);
        CFA_Partner_Program__c partnerProgram = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAcc.CFA_Partner_Program__c];
        partnerProgram.Mobile__c = '1234567890';
        Database.update(partnerProgram, true);
        
        System.runAs(adminUser) {
            Test.startTest();
                String  cfaMobileNumber= EmailUtil.setContactInfo(dealerAcc.id);
            Test.stopTest();

            System.assertEquals('1234567890', cfaMobileNumber, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description test method for getting the number from cfa partner program
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testGetLabelTypeforGMK(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        Account dealerAcc = [SELECT Id, Coop_Type__c, CFA_Partner_Program__c, CFA_Partner_Program__r.Dealer_Portal_Logo__c FROM Account WHERE CIF_Number__c = '314314'];                                                                                      
        dealerAcc.Coop_Type__c = 'Growmark';
        dealerAcc.CFA_Partner_Program__c = null;
        Database.update(dealerAcc, true);
        
        
        System.runAs(adminUser) {
            Test.startTest();
                String  labelType= EmailUtil.getLabelType(dealerAcc.id);
            Test.stopTest();

            System.assertEquals('Growmark',labelType, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description test method for getting the number from cfa partner program
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testGetLabelTypeforCFA(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];

        Account dealerAcc = [SELECT Id, Coop_Type__c FROM Account WHERE CIF_Number__c = '314314'];                                                                                      
        dealerAcc.Coop_Type__c = 'CFA';
        Database.update(dealerAcc, true);
        
        System.runAs(adminUser) {
            Test.startTest();
                String  labelType= EmailUtil.getLabelType(dealerAcc.id);
            Test.stopTest();

            System.assertEquals('GreyLabel',labelType, PortalConstants.ASSERTION_FAILED);
        }

    }

    /**
    * @description test email creation for a growmark user
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testCreateEmailForGrowmark(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        
        Messaging.SingleEmailMessage email;
        System.runAs(adminUser) {
            Test.startTest();
            email=EmailUtil.createEmail('Growmark');
            Test.stopTest();
            System.assert(email!=null, PortalConstants.ASSERTION_FAILED);

        }

    }

    /**
    * @description test email creation for a cfa user
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testCreateEmailForCFA(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        
        Messaging.SingleEmailMessage email;
        System.runAs(adminUser) {
            Test.startTest();
            email=EmailUtil.createEmail('CFA');
            Test.stopTest();
            System.assert(email!=null, PortalConstants.ASSERTION_FAILED);

        }

    }

    /**
    * @description test to get the email template name from db
    * @author Rakesh Saraf | 01-09-2025 
    **/
    @isTest
    static void testGetEmailTemplateNameFomId(){
        User adminUser = [Select id, name from user where Profile.name = 'System Administrator' and isActive = true limit 1];
        List<EmailTemplate> template = [SELECT Id, Name
                                  FROM EmailTemplate
                                  LIMIT 1];

        String templateName='';
        System.runAs(adminUser) {
            Test.startTest();
            templateName=EmailUtil.getTemplateNameFromId(template[0].id);
            Test.stopTest();
            System.assert(templateName!=null, PortalConstants.ASSERTION_FAILED);

        }

    }
}