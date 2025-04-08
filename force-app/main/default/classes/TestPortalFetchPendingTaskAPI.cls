/**
 * @description       : Test class for PortalFetchPendingTaskAPI
 * @author            : Krishanu Chinya | 07-19-2023 
 * @group             : 
 * @last modified on  : 04-05-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
public without sharing class TestPortalFetchPendingTaskAPI {

   @testSetup
   static void setup() {
      //Creating CL Product for Application
      clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
      Database.Insert(clProductObj, true);

      //Creating CL Purpose for Application
      clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
      Database.Insert(clPurposeObj, true);

      //create borrower party
      clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
      // create Dealer party
      clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
      // create certified lender party
      clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
      Database.Insert(new List<clcommon__Party_Type__c>{
         borrowerPartyTypeObj,
         dealerPartyTypeObj,
         clPartyTypeObj
      }, true);

      //Creating Floating Rate Index
      clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
         New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                       'Base Rate Name' => '4-CFA ADVANTAGE',
                                       'Current Floating Rate' => 11,
                                       'Base Rate Adjuster' => 5.5
         });
      Database.Insert(floatingRateIndexObj, true);

      //Creating Floating rate
      clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
      Database.Insert(floatingRateObj, true);

      //Creating New Partner Program
      CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
      Database.Insert(newPartnerProgramObj, true);

      //Creating business information
      genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
      Database.Insert(dealerBusinessInfoObj, true);

      clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
      Database.Insert(entityObj, true);

      //Creating Account for Dealer
      Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
      Database.Insert(dealerAccountObj, true);

      Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, dealerBusinessInfoObj.Id, dealerAccountObj.Id);

      //Creating Account for Certified Lender
      Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
      clAccountObj.ParentId = dealerAccountObj.Id;
      Database.Insert(new List<Account>{
         borrowerAccountObj,
         clAccountObj
      }, true);

      //Creating Contacts
      Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
      Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
      Database.Insert(new List<Contact>{
         borrowerContactObj,
         clContactObj
      }, true);

      //Creating Users
      User clUserObj=ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
      Database.Insert(clUserObj, true);

      //Creating relationship of certified lender
      clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
      Database.Insert(clRoleObj, true);
      clcommon__Relationship__c relationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,
                                                                                                   dealerAccountObj.Id, 
                                                                                                   clAccountObj.Id);
      Database.Insert(relationshipObj, true);

      Map<String,Id> paramForApplicationMap = new Map<String,Id>{
         'dealerAccountId'=> dealerAccountObj.Id,
         'clProductId'=> clProductObj.Id,
         'clPurposeId'=> clPurposeObj.Id,
         'borrowerAccountId'=> borrowerAccountObj.Id,
         'borrowerContactId'=> borrowerContactObj.Id,
         'clAccountId'=> clAccountObj.Id
      };

      genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
      applicationObj.Loan_Id__c = '';
      applicationObj.genesis__Loan_Number__c = '';
      applicationObj.genesis__Loan_Amount__c = 20000;
      applicationObj.genesis__Status__c=PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
      applicationObj.Entity_Documents_Task_Pending__c = true ;
      applicationObj.AOI_Task_Pending__c = true;
      applicationObj.OwnerId=clUserObj.id;

      genesis__Applications__c duplApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
      duplApplicationObj.Loan_Id__c = '';
      duplApplicationObj.genesis__Loan_Number__c = '';
      duplApplicationObj.genesis__Loan_Amount__c = 12000;
      duplApplicationObj.genesis__Status__c=PortalConstants.NEW_SCORECARD_APPLICATION_STATUS;
      duplApplicationObj.Entity_Documents_Task_Pending__c = true ;
      duplApplicationObj.AOI_Task_Pending__c = true;
      duplApplicationObj.OwnerId=clUserObj.id;

      Database.Insert(new List<genesis__Applications__c>{applicationObj,duplApplicationObj}, true);

      List<Task> taskList=createTasks(applicationObj.id);
      Database.insert(taskList,true);

      List<Task> dupApplicationTaskList=createTasks(duplApplicationObj.id);
      Database.insert(dupApplicationTaskList,true);
   }

   /**
    * @description the purpose of this function is to create the tasks for an application
    * @author Rakesh Saraf | 04-04-2025 
    * @param applicationId 
    * @return List<Task> 
    **/
   private static List<Task> createTasks(Id applicationId){
      List<Task> taskList=new List<Task>();

      //creating tasks
      Task aoiTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.AOI_TASK);
      aoiTaskObj.Comments__c='This is a test comment';
      taskList.add(aoiTaskObj);

      Task colRepTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.COLLATERAL_REPORT_TASK);
      taskList.add(colRepTaskObj);

      Task entityDocTaskObj= ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.ENTITY_DOC_TASK);
      taskList.add(entityDocTaskObj);

      Task pauyOffTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.PAYOFF_CONFIRMATION_TASK);
      taskList.add(pauyOffTaskObj);

      Task lienSearchTask = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.LIEN_SEARCH_TASK);
      taskList.add(lienSearchTask);

      Task lianSubTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.LIEN_SUBORDINATION_TASK);
      taskList.add(lianSubTaskObj);

      Task ntbTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.NTB_TASK_CFA_ACTION);
      taskList.add(ntbTaskObj);

      Task cnsTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.CNS_TASK);
      taskList.add(cnsTaskObj);

      Task credAgreementTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.SIGNED_AGREEMENT_TASK);
      taskList.add(credAgreementTaskObj);

      Task spousalConsentTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.SPOUSAL_CONSENT_TASK);
      taskList.add(spousalConsentTaskObj);

      Task uccAmandmentTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.UCC_AMENDMENT_TASK);
      taskList.add(uccAmandmentTaskObj);

      Task uccFilinfTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.UCC_FILING_TASK);
      taskList.add(uccFilinfTaskObj);

      Task custTaskObj = ApplicationOriginationTestHelper.createTask(applicationId, PortalConstants.CUSTOMIZED_LOAN_TASK);
      taskList.add(custTaskObj);

      return taskList;
   }

   /**
   * @description method that has the same query as that in the main class
   * @author Rakesh Saraf | 04-04-2025 
   * @return List<Task> 
   **/
   private static List<Task> getTaskReportList(){
      return [SELECT genesis__Application__c,
                     Comments__c,
                     Subject
                     FROM Task
                     WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                     AND (genesis__Application__r.Entity_Documents_Task_Pending__c = true 
                           OR genesis__Application__r.AOI_Task_Pending__c = true
                           OR genesis__Application__r.Collateral_Report_Task_Pending__c = true
                           OR genesis__Application__r.Payoff_Confirmation_Task_Pending__c = true
                           OR genesis__Application__r.Lien_Search_Task_Pending__c = true
                           OR genesis__Application__r.Lien_Subordination_Task_Pending__c = true
                           OR genesis__Application__r.Security_Notice_Task_Pending__c = true
                           OR genesis__Application__r.CNS_Task_Pending__c = true
                           OR genesis__Application__r.Signed_Agreement_Task_Pending__c = true
                           OR genesis__Application__r.Spousal_Consent_Task_Pending__c = true
                           OR genesis__Application__r.UCC_Amendment_Task_Pending__c = true
                           OR genesis__Application__r.UCC_Filing_Task_Pending__c = true
                           OR genesis__Application__r.Customized_Approval_Task_Pending__c = true)
                     AND genesis__Application__r.genesis__Status__c IN ( :PortalConstants.NEW_ENTERED_APPLICATION_STATUS,
                                                                           : PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS,
                                                                           : PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS,
                                                                           : PortalConstants.NEW_SCORECARD_APPLICATION_STATUS,
                                                                           : PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS)];
   }
   
   /**
    * @description test method to test PortalFetchPendingTaskAPI
    * @author Rakesh Saraf | 04-04-2025 
    **/
   @isTest
   private static void testForSuccess() {
      User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

      List<Task> totalTaskList=[Select id from Task];
      Map<String, Object> request = new Map<String, Object>();
      System.runAs(clUser) {
         Test.startTest();
         PortalFetchPendingTaskAPI portalFetchPendingTaskAPI = new PortalFetchPendingTaskAPI();
         clcommon.Response response = portalFetchPendingTaskAPI.invokeAction('', new List<String>(), request);     
         Test.stopTest();
         
         List<Task> taskList=getTaskReportList();
         System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
         System.assertEquals(totalTaskList.size(), taskList.size(), PortalConstants.ASSERTION_FAILED); 
      }
   }

   /**
   * @description test method to test PortalFetchPendingTaskAPI where both the applications have different status. So, only one application should get queried
   * @author Rakesh Saraf | 04-04-2025 
   **/
   @isTest
   private static void testForApplicationWithDiffStatus() {
      List<genesis__Applications__c> applicationList=[SELECT ID,
                                                             genesis__Status__c
                                                      FROM genesis__Applications__c
                                                      WHERE genesis__Loan_Amount__c = 12000];
      applicationList[0].genesis__Status__c=PortalConstants.PENDING_WITHDRAWAL_APPLICATION_STATUS;
      Database.update(applicationList,true);

      List<Task> totalTaskList=[Select id from Task WHERE genesis__Application__c IN (SELECT ID FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 20000)];
   
      User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      Map<String, Object> request = new Map<String, Object>();
      System.runAs(clUser) {
         Test.startTest();
         PortalFetchPendingTaskAPI portalFetchPendingTaskAPI = new PortalFetchPendingTaskAPI();
         clcommon.Response response = portalFetchPendingTaskAPI.invokeAction('', new List<String>(), request);     
         Test.stopTest();
         
         List<Task> taskList=getTaskReportList();
         System.assertEquals(totalTaskList.size(), taskList.size(), PortalConstants.ASSERTION_FAILED);
         System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
      }
   }
   
   /**
   * @description method to test PortalFetchPendingTaskAPI where none of the applications will get queried.
   * @author Rakesh Saraf | 04-04-2025 
   **/
   @isTest
   private static void testForApplicationsWithExcludingStatus() {
      List<genesis__Applications__c> applicationList=[SELECT ID,
                                                             genesis__Status__c
                                                      FROM genesis__Applications__c];
      applicationList[0].genesis__Status__c=PortalConstants.PENDING_WITHDRAWAL_APPLICATION_STATUS;
      applicationList[1].genesis__Status__c=PortalConstants.REJECTED_APPLICATION_STATUS;
      Database.update(applicationList,true);
         
      User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      Map<String, Object> request = new Map<String, Object>();
      System.runAs(clUser) {
         Test.startTest();
         PortalFetchPendingTaskAPI portalFetchPendingTaskAPI = new PortalFetchPendingTaskAPI();
         clcommon.Response response = portalFetchPendingTaskAPI.invokeAction('', new List<String>(), request);     
         Test.stopTest();
         
         List<Task> taskList=getTaskReportList();
         System.assertEquals(0, taskList.size(), PortalConstants.ASSERTION_FAILED);
         System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
      }
   }


   /**
   * @description method to test PortalFetchPendingTaskAPI where none of the applications will get queried because all the tasks are marked as false on the applications.
   * @author Rakesh Saraf | 04-04-2025 
   **/
   @isTest
   private static void testForApplicationsWithTasksAsFalse() {
      List<genesis__Applications__c> applicationList=[SELECT ID,
                                                             genesis__Status__c
                                                      FROM genesis__Applications__c];
      applicationList[0].Entity_Documents_Task_Pending__c = false ;
      applicationList[0].AOI_Task_Pending__c = false;
      
      applicationList[1].Entity_Documents_Task_Pending__c = false ;
      applicationList[1].AOI_Task_Pending__c = false;
      Database.update(applicationList,true);
         
      User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      Map<String, Object> request = new Map<String, Object>();
      System.runAs(clUser) {
         Test.startTest();
         PortalFetchPendingTaskAPI portalFetchPendingTaskAPI = new PortalFetchPendingTaskAPI();
         clcommon.Response response = portalFetchPendingTaskAPI.invokeAction('', new List<String>(), request);     
         Test.stopTest();
         
         List<Task> taskList=getTaskReportList();
         System.assertEquals(0, taskList.size(), PortalConstants.ASSERTION_FAILED);
         System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
      }
   }
}