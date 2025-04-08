/**
 * @description       : testclass for jwt util
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 05-17-2024
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
private class JWTUtilTest {
    /**
    * @description 
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @TestSetup
    static void setup() {
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
    
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
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

        CFA_Configuration__c credentialParameter = ApplicationOriginationTestHelper.createEmailChangeDecryptionConfig();
        Database.insert(credentialParameter,true);
    }
    
    /**
    * @description : generating a token
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @isTest
    static void testGenerateEmailVerificationToken() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
                Map<String, String> payload = new Map<String, String>{
                    'contactId' => '1237657334',
                    'email' => 'test@example.com'
                };
                String token = JWTUtil.generateEmailVerificationToken(payload);
                System.assertNotEquals(null, token, PortalConstants.ASSERTION_FAILED);
                // Add more specific assertions based on your requirements
            Test.stopTest();
        }

    }
    
    /**
    * @description : testing for a valid token
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @isTest
    static void testIsValidEmailVerificationToken() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
                // Generate a token
                Map<String, String> payload = new Map<String, String>{
                    'userId' => '123',
                    'email' => 'test@example.com'
                };
                String token = JWTUtil.generateEmailVerificationToken(payload);
                
                // Check validity
                Boolean isValid = JWTUtil.isValidEmailVerificationToken(token);
                System.assertEquals(true, isValid, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description : testing for an invalid token
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @isTest
    static void testIsValidEmailVerificationTokenFailure() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
                // Generate a token
                Map<String, String> payload = new Map<String, String>{
                    'userId' => '123',
                    'email' => 'test@example.com'
                };
                String token = JWTUtil.generateEmailVerificationToken(payload);
                token = token.replaceAll('a', 'z');
                token += 'ExtraString';
                
                // Check validity
                Boolean isValid = JWTUtil.isValidEmailVerificationToken(token);
                System.assertEquals(false, isValid, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description : testing the decrypt token method
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @isTest
    static void testDecryptToken() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
                // Generate a token
                Map<String, String> payload = new Map<String, String>{
                    'userId' => '123',
                    'email' => 'test@example.com'
                };
                String token = JWTUtil.generateEmailVerificationToken(payload);
                
                // Decrypt the token
                Map<String, String> decryptedPayload = JWTUtil.decryptToken(token);
                System.assertNotEquals(null, decryptedPayload, PortalConstants.ASSERTION_FAILED);
                // Add more specific assertions based on your requirements
            Test.stopTest();
        }
    }
}