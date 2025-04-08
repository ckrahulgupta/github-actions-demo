/**
 * @description       : This class is used to fetch loan id from NLS and then update it on application. 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Ayan Khanra
**/
global without sharing class FetchLoanIdQueueable implements Queueable , Database.AllowsCallouts{
    
    public static final String CLASS_NAME = 'fetchLoanIdQueueable';
    String loanNumber;
    String applicationId;
    Boolean doNotSendEmail;
    String loanId = '';
    public static final String PAYLOAD = 'payload';
    public static final String DATA = 'data';
   
    /**
    * @description : Constructor to initialize variables
    * @author  Pritam Roy | 03-06-2024 
    * @param loanNumber 
    * @param applicationId 
    **/
    global FetchLoanIdQueueable(String loanNumber, String applicationId){
        this.loanNumber = loanNumber;
        this.applicationId = applicationId; 
        this.doNotSendEmail = false;
    }

    /**
    * @description : Constructor to initialize variables
    * @author  Pritam Roy | 03-06-2024 
    * @param loanNumber 
    * @param applicationId 
    * @param doNotSendEmail 
    **/
    global FetchLoanIdQueueable(String loanNumber, String applicationId, Boolean doNotSendEmail){
        this.loanNumber = loanNumber;
        this.applicationId = applicationId;
        this.doNotSendEmail = doNotSendEmail;
    }
    /**
    * @description : Updates the loanId from nls
    * @author  Pritam Roy | 03-06-2024 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try{
            requestParamMap.put(ConstantValues.LOAN_NUMBER, loanNumber);
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_GET_LOANID,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
            Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
            
            List<Object> fieldResponse = (List<Object>) subResponse.get(DATA);
            
            genesis__Applications__c  objApplication = assignParentLoanId(fieldResponse,applicationId);
            
            if(!objApplication.Non_Accrual__c){
                //runs when the application is in ACCRUAL Status
                objApplication.genesis__Status__c =PortalConstants.ACTIVE_STATUS;
                if(objApplication.Note_Date__c == null){
                    objApplication.Note_Date__c = System.today();
                }
            }
            Database.Update(objApplication, true);
            if(!objApplication.Non_Accrual__c){
                //runs when the application is in ACCRUAL Status
                System.enqueueJob(new FetchChildLoanIdQueueable( objApplication.Loan_Id__c, objApplication.Id,doNotSendEmail));
            }
            
            if(objApplication.Non_Accrual__c && String.valueOf(objApplication.genesis__Loan_Number__c).substring(0,1) == '9'){
                //runs when the application is in NON ACCRUAL Status
                //Update all the loan ids of the child loan associated with this Application
                //Query all the child loans
                List<genesis__Application_Pricing_Detail__c> listOfChildLoansForLoanId = [SELECT Id,
                                                                                                Loan_Id__c,
                                                                                                genesis__Enabled_Flag__c
                                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                                            WHERE genesis__Application__c = :objApplication.Id ];
                for(genesis__Application_Pricing_Detail__c childLoan : listOfChildLoansForLoanId){
                    childLoan.loan_id__c = objApplication.Loan_Id__c;
                }
                Database.update(listOfChildLoansForLoanId);
            }
  
            
  
        }
        catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = CLASS_NAME,
                    clcommon__Message__c = CLASS_NAME  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
        }
    }

    /**
    * @description 
    * @author Ayan Khanra | 03-25-2025 
    * @param fieldResponse 
    * @param applicationId 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c assignParentLoanId(List<Object> fieldResponse, Id applicationId){
        Map<String, Object>  responseMap = new Map<String, Object>();
        genesis__Applications__c applicationObj = [SELECT Id, 
                                                            Crop_Year__c,
                                                            Peak_Loan_Volume__c,
                                                            Loan_Id__c,
                                                            genesis__Status__c,
                                                            Non_Accrual__c,
                                                            genesis__Loan_Number__c,
                                                            Note_Date__c
                                                    FROM genesis__Applications__c
                                                    WHERE Id = :applicationId];
        if(fieldResponse.isEmpty()){
            applicationObj.Loan_Id__c = null;
        }else{
            responseMap = (Map<String,Object>) fieldResponse[0];
            applicationObj.Loan_Id__c =  responseMap.get('Acctrefno')!= null ? String.valueOf(responseMap.get('Acctrefno')) : null;
        } 
        return applicationObj;                                  
    }
  }