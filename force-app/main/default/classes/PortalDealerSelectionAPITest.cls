/********************************************
 * @description       : this is a test class for PortalDealerSelectionAPI 
 * @author            : Krishanu Chinya
 * @created date      : 09-13-2023
 * @group             : 
 * @last modified on  : 09-13-2023
 * @last modified by  : Krishanu Chinya
*******************************************/

@isTest
public with sharing class PortalDealerSelectionAPITest {
    @testSetup
     static void setup() {
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(dealerAccountObj, true);

        // Creating Contact for Dealer
        Contact dealerContactObj = TestClassHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);

        //creating another dealer account

        // creating business information
        dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Name = 'Krishi Loan';
        dealerAccountObj.CIF_Number__c = '091285';
        dealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(dealerAccountObj, true);
      //creating another dealer account

        // creating business information
        dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Name = 'Krishi Credit';
        dealerAccountObj.CIF_Number__c = '091286';
        Database.insert(dealerAccountObj, true);
     }

    // test case 1 to test the success scenerio
    @isTest
    public static void testForSuccess() {
        
       User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
       Map<String, Object> request = new Map<String, Object>();
       Account dealerAcc = [SELECT Id, CIF_Number__c FROM Account WHERE CIF_Number__c = '091284'];
       request.put('dealerAccountId', dealerAcc.Id);
       if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
               Test.startTest();
               PortalDealerSelectionAPI portalDealerSelectionAPI = new PortalDealerSelectionAPI();
               clcommon.Response response = portalDealerSelectionAPI.invokeAction('', new List<String>(), request);     
               Test.stopTest();
               System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
           }
       }
    }

   // test case to test the exception scenerio
   @isTest
   public static void testForFailure() {
       
      User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
      Map<String, Object> request = new Map<String, Object>();
      Account dealerAcc = [SELECT Id, CIF_Number__c FROM Account WHERE CIF_Number__c = '091286'];
      request.put('dealerAccountId', dealerAcc.Id);
      if(objCertifiedLenderUser != null) {
           System.runAs(objCertifiedLenderUser) {
              Test.startTest();
              PortalDealerSelectionAPI portalDealerSelectionAPI = new PortalDealerSelectionAPI();
              clcommon.Response response = portalDealerSelectionAPI.invokeAction('', new List<String>(), request);     
              Test.stopTest();
              System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'SUCCESS'); 
          }
      }
   }

   // test case to test the exception scenerio
   @isTest
   public static void testForFailureBlankRequest() {
       
      User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
      Map<String, Object> request = new Map<String, Object>();
      if(objCertifiedLenderUser != null) {
           System.runAs(objCertifiedLenderUser) {
              Test.startTest();
              PortalDealerSelectionAPI portalDealerSelectionAPI = new PortalDealerSelectionAPI();
              clcommon.Response response = portalDealerSelectionAPI.invokeAction('', new List<String>(), request);     
              Test.stopTest();
              System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'SUCCESS'); 
          }
      }
   }
     
}