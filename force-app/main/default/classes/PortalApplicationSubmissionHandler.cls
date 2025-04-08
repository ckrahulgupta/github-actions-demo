/**
 * @description       : a handler class dedicated to PortalApplicationSubmissionApi
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Ayush Kumar Singh
**/
public inherited sharing class PortalApplicationSubmissionHandler {
    
    /**
    * @description this method is to return the list of applications for the class PortalApplicationSubmissionApi
    * @author Rakesh Saraf | 10-22-2024 
    * @param applicationId 
    * @return List<genesis__Applications__c> 
    **/
    public static List<genesis__Applications__c> getApplicationDetails(Id applicationId){
        //get the application details
        List<genesis__Applications__c> currentApplicationList=[SELECT Id, 
                                                                        CreatedDate,
                                                                        genesis__Expected_Start_Date__c,
                                                                        genesis__Expected_First_Payment_Date__c,
                                                                        Dealer_Name__c,
                                                                        Name,
                                                                        My_Program__c,
                                                                        Flex_Rate_Pricing__c,
                                                                        genesis__Loan_Number__c,
                                                                        genesis__Account__c,
                                                                        genesis__Account__r.CIF_Number__c,
                                                                        genesis__Account__r.Score_1__c,
                                                                        genesis__Status__c,
                                                                        Additional_Information_Needed__c,
                                                                        genesis__Loan_Amount__c,
                                                                        genesis__Credit_Rating__c,
                                                                        genesis__Credit_Rating__r.Name,
                                                                        Signing_Method__c,
                                                                        Credit_Application_And_Agreement_Process__c,
                                                                        Evergreen_Tier_Two_Business_Info_Status__c,
                                                                        genesis__Parent_Application__c,
                                                                        genesis__Parent_Application__r.Crop_Year__c,
                                                                        Crop_Year__c,
                                                                        Lien_Options__c,
                                                                        Is_Evergreen__c,
                                                                        Net_Worth__c,
                                                                        Agreement_Sign__c,
                                                                        Coop_Type__c,
                                                                        Dealer_name__r.CFA_Partner_Program__c,
                                                                        Dealer_name__r.CFA_Partner_Program__r.Name,
                                                                        Dealer_name__r.CFA_Partner_Program__r.Allow_Auto_Booking__c,
                                                                        FICO_Score__c,
                                                                        SBSS_70_Score__c,
                                                                        Guarantee__c,
                                                                        Jointly_Payable_Proceeds_Checks__c,
                                                                        Spousal_Consent__c,
                                                                        Assignment_Of_Insurance__c,
                                                                        Blanket_Lien__c,
                                                                        Lien_Position__c,
                                                                        Crops_Lien__c,
                                                                        Stage__c,
                                                                        Pricing_Count__c,
                                                                        Dealer_Name__r.CFA_Partner_Program__r.Statement_Code_Single_Rate_Opt_Out__c,
                                                                        Dealer_Name__r.CFA_Partner_Program__r.Statement_Code_Multi_Rate_Opt_Out__c,
                                                                        Statement_Code__c,
                                                                        Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c,
                                                                        Dealer_Name__r.genesis__Business_Information__r.Customised_Individual_Limit__c,
                                                                                (SELECT Id,
                                                                                Street__c,
                                                                                City__c,
                                                                                State__c,
                                                                                County__c,
                                                                                Postal_Code__c,
                                                                                Mobile_Number__c,
                                                                                Home_Number__c,
                                                                                Work_Number__c,
                                                                                Marital_Status__c,
                                                                                clcommon__Party_Types__c,
                                                                                clcommon__Account__c,
                                                                                clcommon__Account__r.Score_1__c,
                                                                                clcommon__Contact__c,
                                                                                genesis__Application__c,
                                                                                clcommon__Type__r.Name,
                                                                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                                clcommon__Account__r.genesis__Business_information__c,
                                                                                clcommon__Contact__r.clcommon__Marital_Status__c,
                                                                                Total_Assets__c,
                                                                                Total_Liabilities__c
                                                                        FROM genesis__Parties__r
                                                                        WHERE clcommon__Party_Types__c IN (:PortalConstants.PRINCIPAL_PARTY_NAME,:PortalConstants.BORROWER_PARTY_NAME))
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId
                                                                LIMIT 1];
        PortalApplicationOriginationHelper.checkEmptyList(currentApplicationList,PortalConstants.SOMETHING_WENT_WRONG);
        return currentApplicationList;
    }

    /**
    * @description get the principals for the application
    * @author Rakesh Saraf | 11-04-2024 
    * @param applicationObj 
    * @return List<clcommon__Party__c> 
    **/
    public static List<clcommon__Party__c> getPrincipalPartyList(genesis__Applications__c applicationObj){
        //getting the list of principals linked to the application
        List<clcommon__Party__c> appPrincipalList=new List<clcommon__Party__c>();
        for(clcommon__Party__c eachParty:applicationObj.genesis__Parties__r){
            if(eachParty.clcommon__Party_Types__c==PortalConstants.PRINCIPAL_PARTY_NAME){
                appPrincipalList.add(eachParty);
            }
        }
        return appPrincipalList;
    }

    /**
    * @description the purpose of this method is to retrieve the my program related to the application
    * @author Rakesh Saraf | 10-22-2024 
    * @param applicationObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c getMyProgram(genesis__Applications__c applicationObj){

        List<genesis__Rate_Card_Setup_Header__c> myProgramList=new List<genesis__Rate_Card_Setup_Header__c>();
        if(!applicationObj.Flex_Rate_Pricing__c &
                !String.isBlank(applicationObj.My_Program__c)){
                    myProgramList = [SELECT  genesis__End_Date__c,
                                                        genesis__Start_Date__c,
                                                        Crop_Year__c,
                                                        Base_Rate__c
                                                FROM genesis__Rate_Card_Setup_Header__c
                                                WHERE Id = :applicationObj.My_Program__c
                                                LIMIT 1];
                    return myProgramList[0];
        }
        return null;
    }
    


    /**
    * @description Purpose of this method is to update Status of Task.
    * @author Rakesh Saraf | 10-22-2024 
    * @param currentApplicationList 
    * @param shouldDeny 
    **/
    public static void checkTask(List<genesis__Applications__c> currentApplicationList,Boolean shouldDeny){
        //if the credit application or agreement process of the application is null(save and exit) or if the applicationi is not recommended, we will not do anything
        if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c == null | 
            shouldDeny){
                return;
        }

        //Querying the tasks related to the application
        List<Task> customizedTaskList = [SELECT Id, 
                                                Subject,
                                                Status
                                        FROM Task
                                        WHERE Subject IN (:PortalConstants.CUSTOMIZED_LOAN_TASK, :PortalConstants.NTB_TASK_CFA_ACTION, :PortalConstants.AOI_TASK, :PortalConstants.SPOUSAL_CONSENT_TASK)  
                                        AND genesis__Application__c = :currentApplicationList[0].Id];

                                        
        
        //looping through the tasks
        for(Task taskObj:customizedTaskList){
            if(taskObj.Subject == PortalConstants.CUSTOMIZED_LOAN_TASK){
                updateCustomizedLoanTask(currentApplicationList,taskObj);
            }
            else if(taskObj.Subject == PortalConstants.NTB_TASK_CFA_ACTION){
                updateSecurityActionTask(currentApplicationList,taskObj);
            }
            else if(taskObj.Subject == PortalConstants.AOI_TASK){
                updateInsuranceAssignmentTask(currentApplicationList, taskObj);
            }
            else{
                updateSpousalConsentTask(currentApplicationList, taskObj);
            }
        }
        Database.update(customizedTaskList,true);
    }

    /**
    * @description update the fields of the task for Customized Loan Approval
    * @author Rakesh Saraf | 10-29-2024 
    * @param currentApplicationList 
    * @param taskObj 
    **/
    private static void updateCustomizedLoanTask(List<genesis__Applications__c> currentApplicationList,Task taskObj){
        if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c == PortalConstants.CUSTOMIZE_LOAN){
            //If Credit_Application_And_Agreement_Process__c == cutomize Then Guarantee should be 100% as GUARANTEE_FOR_TIER_4 is 100 by default We choose this custom label

            taskObj.Status = PortalConstants.COMPLETED_TASK_STATUS;
            currentApplicationList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_4);
        }
        else{
            updateGuaranteeForApplication(currentApplicationList[0]);
            //Mark the Application as Unsecured for Tier 1 && Secured for Tier 2/3/4
            //if tier 1 and not growmark application Lien_Options__c should be unsecured
            if(currentApplicationList[0].genesis__Credit_Rating__r.Name == PortalConstants.TIER_1_CREDIT &
                currentApplicationList[0].Coop_Type__c != PortalConstants.GROWMARK_COOP_TYPE){
                    currentApplicationList[0].Lien_Options__c= PortalConstants.UNSECURED_LIEN;
            }
            else{
                currentApplicationList[0].Lien_Options__c = PortalConstants.SECURED_LIEN;
            }
            currentApplicationList[0].Blanket_Lien__c= null;
            currentApplicationList[0].Crops_Lien__c=null;
            currentApplicationList[0].Lien_Position__c= null;
            taskObj.Status = PortalConstants.OPEN_TASK_STATUS;
        }
    }

    /**
    * @description updates the value of the guarantee of the application.
    * @author Rakesh Saraf | 11-29-2024 
    * @param currentApplication
    **/
    private static void updateGuaranteeForApplication(genesis__Applications__c currentApplication){
        Integer ficoScore;
        Integer sbssScore;
        Double loanAmount;
        Decimal netWorth;

        if(currentApplication.FICO_Score__c != null){
            ficoScore = integer.valueOf(currentApplication.FICO_Score__c);
        }
        if(currentApplication.SBSS_70_Score__c != null){
            sbssScore = integer.valueOf(currentApplication.SBSS_70_Score__c);
        }
        loanAmount = currentApplication.genesis__Loan_Amount__c;
        if(currentApplication.Net_Worth__c != null){
            netWorth = Decimal.valueOf(currentApplication.Net_Worth__c);
        }
        
        //Categorising the appplication into different Tiers depending upon the ficoScore, sbssScore and Networth
        if(ficoScore > Integer.valueOf( ConstantValues.FICO_MIN_TIER_1) 
            & ficoScore <= Integer.valueOf(ConstantValues.FICO_MAX_TIER_1)
            & sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1) 
            & netWorth >= 4*loanAmount){

            currentApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);

        }
        else if(ficoScore > Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) 
                & ficoScore <= Integer.valueOf(ConstantValues.FICO_MAX_TIER_1)
                & sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2) 
                & netWorth>=loanAmount){
            currentApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_2);
        }
        //Condition Check for Tier 3
        else if((ficoScore > Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) 
                    & sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) 
                    & netWorth>0)
                //If Score is more than 899 - Credit Bureau is Locked
                |  (ficoScore > Integer.valueOf(ConstantValues.FICO_MAX_TIER_1))
                //If no Score is Returned
                |  (ficoScore == 0 & sbssScore == 0 & netWorth>0)){
            
            currentApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
        }
        //Condition Check for Tier 4
        else if((ficoScore <= Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) &
                ficoScore > 0 ) 
                |
                (sbssScore <= Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) &
                sbssScore > 0 )
                |
                netWorth < 0){
                    
                    if(currentApplication.Dealer_Name__c != null &
                        currentApplication.Dealer_Name__r.genesis__Business_Information__c != null &
                        currentApplication.Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c > 0 &
                        currentApplication.Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c != null){
                            //Dealer can customise
                            currentApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_4);
                    }
                    else{
                        currentApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);
                    }
            
        }
        else{
            
            currentApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
        }
    }

    /**
    * @description update the fields of the task for Notice of Security Action Task
    * @author Rakesh Saraf | 10-29-2024 
    * @param currentApplicationList 
    * @param taskObj 
    **/
    private static void updateSecurityActionTask(List<genesis__Applications__c> currentApplicationList,Task taskObj){
        //if the credit application and agreement process of the application is customize and the jointly payable proceeds is checked, we change the sttus of the task to completed
        if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c == PortalConstants.CUSTOMIZE_LOAN &
            currentApplicationList[0].Jointly_Payable_Proceeds_Checks__c == true){
                taskObj.Status = PortalConstants.COMPLETED_TASK_STATUS;
        }
        else{
            //else, we mark it to be open
            taskObj.Status = PortalConstants.OPEN_TASK_STATUS;
        }
    }

    /**
    * @description update the fields of the task for Assignment of Insurance Task
    * @author Rakesh Saraf | 10-29-2024 
    * @param currentApplicationList 
    * @param taskObj 
    **/
    private static void updateInsuranceAssignmentTask(List<genesis__Applications__c> currentApplicationList,Task taskObj){
        //if the credit application and agreement process is customize and the assignment of insurance is true, the task status will be complete
        if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c == PortalConstants.CUSTOMIZE_LOAN &
            currentApplicationList[0].Assignment_Of_Insurance__c == true){                  
                taskObj.Status = PortalConstants.COMPLETED_TASK_STATUS;                    
        }
        else{
            //else it is open
            taskObj.Status = PortalConstants.OPEN_TASK_STATUS;   
        }
    }

    /**
    * @description update the fields of the task for Spousal Consent Task
    * @author Rakesh Saraf | 10-29-2024 
    * @param currentApplicationList 
    * @param taskObj 
    **/
    private static void updateSpousalConsentTask(List<genesis__Applications__c> currentApplicationList,Task taskObj){
        //if the credit application and agreement process is customize and the spousal consent is true, the task status will be complete
        if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c == PortalConstants.CUSTOMIZE_LOAN &
            currentApplicationList[0].Spousal_Consent__c == true){
                taskObj.Status = PortalConstants.COMPLETED_TASK_STATUS;
        }
        else{
            //else it will be marked as open
            taskObj.Status = PortalConstants.OPEN_TASK_STATUS;
        }
    }

    /**
    * @description updating the applications terms for Save and Exit
    * @author Rakesh Saraf | 10-29-2024 
    * @param applicationObj 
    * @param applicationMyProgramObj 
    **/
    public static void updateApplicationTerms(genesis__Applications__c applicationObj,genesis__Rate_Card_Setup_Header__c applicationMyProgramObj){
        if(applicationMyProgramObj.genesis__End_Date__c != null){
            //put my program's maturity date to applicationObj's maturity date
            applicationObj.genesis__Maturity_Date__c = applicationMyProgramObj.genesis__End_Date__c;
        }
        if(applicationMyProgramObj.Crop_Year__c != null){
            //populating the Crop Year field on the applicationObj level with the crop year of the my program selected
            applicationObj.Crop_Year__c = applicationMyProgramObj.Crop_Year__c;
        }
        //get the term calculated as per the maturity date
        Integer applicationTerm = System.today().monthsBetween(applicationObj.genesis__Maturity_Date__c);
        if(applicationObj.genesis__Maturity_Date__c.day() > System.today().day()){
            applicationTerm++;
        }
        applicationObj.genesis__Term__c = applicationTerm;
    }

    /**
    * @description check if autobook is possible for the application
    * @author Rakesh Saraf | 10-23-2024 
    * @param autoBookParams 
    * @param autoBookListParams 
    * @return Boolean 
    **/
    public static Boolean updateAutoBook(Map<String,Object> autoBookParams,Map<String,List<Object>> autoBookListParams){
        Boolean isAutoBookPossible=(Boolean) autoBookParams.get(PortalConstants.IS_AUTOBOOK_POSSIBLE);
        Id borrowerAccountId=(Id)autoBookParams.get(PortalConstants.KEY_BORROWER_ACC);
        
        List<genesis__Applications__c> currentApplicationList=(List<genesis__Applications__c>) autoBookListParams.get(PortalConstants.CURRENT_APPLICATION);
        List<clcommon__Party__c> appPrincipalPartyList=(List<clcommon__Party__c>) autoBookListParams.get(PortalConstants.KEY_PRINCIPAL);
        List<ID> principalAccountIdList=(List<ID>) autoBookListParams.get(PortalConstants.KEY_PRINICPAL_ACC);

        List<Id> borrowerPrincipalIdList =principalAccountIdList;


        //Check whether the applicant borrower is new or not
        //query on party to get the number of booked applications(loans) where the borrower is present
        Map<String, Id> partyTypeMap = PortalApplicationOriginationHelper.getPartyTypeMap();
        Map<String, List<Id>> autoBookMap = new Map<String,List<Id>>();
        
        //getting the latest active applications of the borrower
        List<clcommon__Party__c> borrowerExistingPartyList = [SELECT  Id,
                                                                clcommon__Account__c,
                                                                genesis__Application__c
                                                        FROM clcommon__Party__c
                                                        WHERE clcommon__Account__c = :currentApplicationList[0].genesis__Account__c AND
                                                            clcommon__Type__c = :partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME) AND 
                                                            genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                        ORDER BY CreatedDate DESC];
        
        //check if the applicant exists or not, if there exists and applications, it means that the borrower already exists.
        if(!borrowerExistingPartyList.isEmpty()){
            //Existing Borrower
            //get the principals of the existing application which is active
            List<clcommon__Party__c> principalExistingAppList = [SELECT  Id,
                                                                        clcommon__Account__c
                                                                    FROM clcommon__Party__c
                                                                    WHERE genesis__Application__c = :borrowerExistingPartyList[0].genesis__Application__c AND
                                                                        clcommon__Type__c = :partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME)];
            map<String,String> comparePartyMap = new Map<String,String>();
            //getting all the principals of the current application in a map
            for(clcommon__Party__c eachParty : appPrincipalPartyList){
                comparePartyMap.put((String)eachParty.clcommon__Account__c,PortalConstants.ACCOUNT_KEY);
            }

            //Querying the entity document task
            List<Task> entityDocumentTaskList = [SELECT Status,
                                                Subject
                                            FROM Task
                                            WHERE genesis__Application__c = :currentApplicationList[0].Id
                                            AND Subject = :PortalConstants.ENTITY_DOC_TASK
                                            LIMIT 1];
            
            PortalApplicationOriginationHelper.checkEmptyList(entityDocumentTaskList, PortalConstants.SOMETHING_WENT_WRONG);

            // Check entity document submission task is done or not, if not -> Pending Approval
            // Check Tier 1 / Tier 2, if not -> Pending Approval
            // Check whether Docusign is done or not, if not -> Pending Approval

            Map<String,List<Object>> paramMap=new Map<String,List<Object>>{
                PortalConstants.CURRENT_APPLICATION=>currentApplicationList,
                PortalConstants.KEY_PRINCIPAL=>appPrincipalPartyList,
                PortalConstants.KEY_PRINCIPAL_EXISTING=>principalExistingAppList,
                PortalConstants.ENTITY_DOC_TASK_KEY=>entityDocumentTaskList
            };

            if(!checkAutoBookingForExistingBorrower(paramMap)){

                    //move the application to pending approval
                    currentApplicationList[0].genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS; 
            }
            else{

                //this means that the number of principals on this application and the most recent active application of the borrower is same. Next we check if the borrowers are ctually same. If so, autobook will be possible
                isAutoBookPossible=checkApplicationsHaveSamePrincipal(principalExistingAppList,comparePartyMap,currentApplicationList[0]);
                
                currentApplicationList[0].genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
            }
        }
        else{
            //New Borrower checked
            //Querying on the party to get the entity type 
            List<clcommon__Party__c> borrowerPartyList =[SELECT  Id, 
                                                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c = :currentApplicationList[0].Id AND
                                                        clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME
                                                        LIMIT 1];

            PortalApplicationOriginationHelper.checkEmptyList(borrowerPartyList, PortalConstants.SOMETHING_WENT_WRONG);
                                                        
            //Check entity type to be sole proprietor, with dba, if not -> Pending Approval
            //Check Tier 1 / Tier 2, if not -> Pending Approval 
            //Check whether Docusign is done or not, if not -> Pending Approval
            if(!checkAutoBookingForNewBorrower(currentApplicationList,borrowerPartyList)){
                    //No Autobooking possible
                    currentApplicationList[0].genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
                }
            else{

                // setting the autobook flag here
                // we would use it for book-to-core at the end of the invoke action method
                isAutoBookPossible = true;
                currentApplicationList[0].genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
            }
        } 

        // borrowerPrincipalIdList = principalAccountIdList;
        borrowerPrincipalIdList.add(borrowerAccountId);
        autoBookMap.put('borrowerPrincipalIdList',borrowerPrincipalIdList);
        autoBookMap.put('dealerIdList',new List<Id>{currentApplicationList[0].Dealer_Name__c});
        isAutoBookPossible=updateAutobookForNonAccuralLoans(autoBookMap,isAutoBookPossible);

        return isAutoBookPossible;
    }


    /**
    * @description checks if the application will be eligible for autobook
    * @author Rakesh Saraf | 10-29-2024 
    * @param paramMap 
    * @return Boolean 
    **/
    private static Boolean checkAutoBookingForExistingBorrower(Map<String,List<Object>> paramMap){
        List<genesis__Applications__c> currentApplicationList=(List<genesis__Applications__c>) paramMap.get(PortalConstants.CURRENT_APPLICATION);
        List<clcommon__Party__c> appPrincipalPartyList=(List<clcommon__Party__c>) paramMap.get(PortalConstants.KEY_PRINCIPAL);
        List<clcommon__Party__c> principalExistingAppList=(List<clcommon__Party__c>) paramMap.get(PortalConstants.KEY_PRINCIPAL_EXISTING);
        List<Task> entityDocumentTaskList=(List<Task>) paramMap.get(PortalConstants.ENTITY_DOC_TASK_KEY);

        //if the application is neither a tier 1 nor a tier 2 applications, it wont be eligible for autobooking
        //if the signing method for the application is paper scanned i.e, it is neither email docusign, nor in person docusing nor in person hybrid, then it will not be eligible
        //if the loan amount exceeds the loan limit for autobooking, it will not be eligible for autobooking
        //if the status of the task where the subject is Entity Documnts is open, it will not be eligible for autobooking
        if(currentApplicationList[0].Signing_Method__c == PortalConstants.PAPER_SCANNED | 
            (currentApplicationList[0].genesis__Credit_Rating__r.Name != PortalConstants.TIER_1_CREDIT & currentApplicationList[0].genesis__Credit_Rating__r.Name != PortalConstants.TIER_2_CREDIT) |
            (currentApplicationList[0].genesis__Loan_Amount__c > Decimal.valueOf(PortalConstants.LOAN_LIMIT_FOR_AUTO_BOOKING)) |
            (appPrincipalPartyList.size() != principalExistingAppList.size()) |
            (entityDocumentTaskList[0].Status != PortalConstants.OPEN_TASK_STATUS)){
                
            return false;
        }
        return true;
    }

    /**
    * @description check if the application with a new borrower is eligible for autobooking or not.
    * @author Rakesh Saraf | 10-30-2024 
    * @param currentApplicationList 
    * @param borrowerPartyList 
    * @return Boolean 
    **/
    private static Boolean checkAutoBookingForNewBorrower(List<genesis__Applications__c> currentApplicationList,List<clcommon__Party__c> borrowerPartyList){
        //f the application is neither a tier 1 nor a tier 2 applications, it wont be eligible for autobooking
        //if the signing method for the application is paper scanned i.e, it is neither email docusign, nor in person docusign nor in person hybrid, then it will not be eligible
        //if the loan amount exceeds the loan limit for autobooking, it will not be eligible for autobooking
        //if the borrower is not a sole prop, it will not be eligible for autobooking

        if((currentApplicationList[0].Signing_Method__c == PortalConstants.PAPER_SCANNED) |
                (currentApplicationList[0].genesis__Credit_Rating__r.Name != PortalConstants.TIER_1_CREDIT & currentApplicationList[0].genesis__Credit_Rating__r.Name != PortalConstants.TIER_2_CREDIT) |
                (borrowerPartyList[0].clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY) |
                (currentApplicationList[0].genesis__Loan_Amount__c > Decimal.valueOf(PortalConstants.LOAN_LIMIT_FOR_AUTO_BOOKING))){
                return false;
            }
            return true;
    }


    /**
    * @description checks whether applications of the same borrower have the same principals or not.
    * @author Rakesh Saraf | 10-30-2024 
    * @param principalExistingAppList 
    * @param comparePartyMap 
    * @param applicationObj 
    * @return Boolean 
    **/
    private static Boolean checkApplicationsHaveSamePrincipal(List<clcommon__Party__c> principalExistingAppList,Map<String,String> comparePartyMap,genesis__Applications__c applicationObj){
        Boolean areSameCoApplicants = true;

        //Check whether both the applications with same borrower have same principals
        for(clcommon__Party__c eachParty : principalExistingAppList){
            if(!comparePartyMap.containsKey(eachParty.clcommon__Account__c)){
                //Different principals are present under same borrower
                applicationObj.genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;

                areSameCoApplicants = false;
                break;
            }
        }
        return areSameCoApplicants;
    }

    
    /**
    * @description this method helps in generating pricing
    * @author Rakesh Saraf | 11-13-2024 
    * @param currentApplicationObj 
    * @param applicationMyProgramObj 
    **/
    public static void generatePricing(genesis__Applications__c currentApplicationObj,genesis__Rate_Card_Setup_Header__c applicationMyProgramObj){

        //method to update the terms of the application    
        updateApplicationTerms(currentApplicationObj, applicationMyProgramObj);

        // update the expected start date & the expected 1st payment
        // date for the application if the My Program is created after the application
        if(currentApplicationObj.genesis__Expected_Start_Date__c <= applicationMyProgramObj.genesis__Start_Date__c) {

            currentApplicationObj.genesis__Expected_Start_Date__c = applicationMyProgramObj.genesis__Start_Date__c.addDays(1);
            currentApplicationObj.genesis__Expected_First_Payment_Date__c = currentApplicationObj.genesis__Expected_Start_Date__c.addMonths(1);

        }

        //calling snippet to generate eligible pricings.child loans
        generateChildLoans(currentApplicationObj);
        
        
    }

    /**
    * @description generates the child loans for the application
    * @author Rakesh Saraf | 11-13-2024 
    * @param currentApplicationObj 
    **/
    public static void generateChildLoans(genesis__Applications__c currentApplicationObj){

        List<genesis__Application_Pricing_Detail__c> appPricingList = new List<genesis__Application_Pricing_Detail__c>();
        
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,
                                                                            genesis__Interest_Rate__c 
                                                                    FROM genesis__Rate_Card_Setup_Detail__c   
                                                                    WHERE genesis__Rate_Card_Setup_Header__c  = :currentApplicationObj.My_program__c AND 
                                                                            genesis__Enabled_Flag__c = true];
        List<genesis__Application_Pricing_Detail__c> existinAppPricingList = [SELECT Id, 
                                                                        genesis__Application__c 
                                                                    FROM genesis__Application_Pricing_Detail__c
                                                                    WHERE genesis__Application__c =: currentApplicationObj.id];
        if(!existinAppPricingList.isEmpty()){
            Database.delete(existinAppPricingList,true);
        }
        for(genesis__Rate_Card_Setup_Detail__c eachPricing : rateCardSetupDetailList){
            genesis__Application_Pricing_Detail__C pricingObj  = new genesis__Application_Pricing_Detail__C();
            pricingObj.genesis__Rate_Card_Setup_Detail__c = eachPricing.Id;
            pricingObj.genesis__Interest_Rate__c = eachPricing.genesis__Interest_Rate__c;
            pricingObj.genesis__Application__c = currentApplicationObj.Id;
            appPricingList.add(pricingObj);
        }
        Database.insert(appPricingList,true);          
        
    }

    /**
    * @description updates Loan Number
    * @author Rakesh Saraf | 10-23-2024 
    * @param applicationObj 
    * @param shouldDeny 
    **/
    public static void generatesLoanNumber(genesis__Applications__c applicationObj,Boolean shouldDeny){
        //if the application is not recommended, we dont update anything
        if(shouldDeny || 
            applicationObj.genesis__Loan_Number__c != NULL){
                return;
        }
        //getting the map of id with party types
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        mapOfpartyType = PortalHelper.getPartyTypeMap();
        List<clcommon__Party__c> existingBorrowerPartyList = [SELECT Id,  
                                                                    clcommon__Account__c 
                                                                FROM clcommon__Party__c 
                                                                WHERE clcommon__Party_Types__c =: PortalConstants.BORROWER_PARTY_NAME
                                                                AND genesis__Application__r.genesis__Status__c IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                                                :PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS,
                                                                                                                :PortalConstants.CLOSED_APPLICATION_STATUS)
                                                                AND genesis__Application__r.Submitted_to_CFA__c != NULL
                                                                AND clcommon__Account__c=:applicationObj.genesis__Account__c];
        if(!existingBorrowerPartyList.isEmpty()){
            //it means that the borrower is an existing borrower. Hence, we pick the last submitted application of the borrower and use its loan number to update this one's loan number
            applicationObj.genesis__Loan_Number__c = generateLoanNumber(applicationObj, PortalConstants.EXISTING_APPLICANT, mapOfpartyType);
        }else{
            //this means that the borrower is a new borrower, o we need to use the cif number to genrrate a loan number
            applicationObj.genesis__Loan_Number__c = generateLoanNumber(applicationObj, PortalConstants.NEW_APPLICANT, mapOfpartyType);
        }

    }

    /**
    * @description method to generate the loan number of an application
    * @author Rakesh Saraf | 11-13-2024 
    * @param applicationObj 
    * @param shouldValidate 
    * @param mapOfpartyType 
    * @return String 
    **/
    private static String generateLoanNumber(genesis__Applications__c applicationObj, String shouldValidate, Map<String, Id> mapOfpartyType){
        String loanNumber = PortalConstants.EMPTY_STRING;
        //Query the Latest Loan for the Grower
        List<clcommon__party__c> partyList = [SELECT Id,
                                                            genesis__Application__r.genesis__Loan_Number__c
                                                FROM clcommon__party__c
                                                WHERE clcommon__Account__c =: applicationObj.genesis__Account__c
                                                AND clcommon__Type__c =: mapOfpartyType.get(PortalConstants.BORROWER_PARTY_NAME)
                                                AND genesis__Application__r.genesis__Status__c IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                                    :PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS,
                                                                                                    :PortalConstants.CLOSED_APPLICATION_STATUS)
                                                AND genesis__Application__r.Submitted_to_CFA__c != NULL
                                                ORDER BY genesis__Application__r.genesis__Loan_Number__c DESC];
        if(shouldValidate == PortalConstants.NEW_APPLICANT){
            loanNumber = applicationObj.genesis__Account__r.CIF_Number__c + PortalConstants.CIF_SUFFIX;
        }
        else{
            loanNumber = String.valueOf((Decimal.valueOf(partyList[0].genesis__Application__r.genesis__Loan_Number__c) + PortalConstants.ONE_VALUE));
        }
        return loanNumber;
     }

    /**
    * @description updates the pricing detail for an application
    * @author Rakesh Saraf | 10-23-2024 
    * @param applicationObj 
    * @param applicationPricingList 
    * @param activePricingCount
    * @return Integer
    **/
    public static Integer updateApplicationPricing(genesis__Applications__c applicationObj,List<genesis__Application_Pricing_Detail__c> applicationPricingList, Integer activePricingCount){
        //query all the pricing related to the application
        List<genesis__Application_Pricing_Detail__c> appPricingGeneratedList = [SELECT  Id,
                                                                                        genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                        Loan_Number__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c,
                                                                                        Name,
                                                                                        genesis__Enabled_Flag__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.Start_date__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.End_date__c
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                                WHERE genesis__Application__c = :applicationObj.Id];

        if(appPricingGeneratedList.isEmpty()){
            return null;
        }

        //here we will generate the loan number for all the pricings
        for(genesis__Application_Pricing_Detail__c individualPricing : appPricingGeneratedList){
            String specialTermNumber = String.valueOf(individualPricing.genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c).substringBetween(PortalConstants.SPL_SUB_TRANCHE_STRING,PortalConstants.CLOSING_BRACKET_STRING);
            individualPricing.Loan_Number__c = applicationObj.genesis__Loan_Number__c + PortalConstants.HYPHEN_STRING + specialTermNumber;  
            //disable only the pricing with start date after todays date
            if(individualPricing.genesis__Rate_Card_Setup_Detail__c != null &&
                individualPricing.genesis__Rate_Card_Setup_Detail__r.Start_date__c != null &&
                    (individualPricing.genesis__Rate_Card_Setup_Detail__r.Start_date__c > System.today() || 
                    individualPricing.genesis__Rate_Card_Setup_Detail__r.End_date__c < System.today() )){
                        individualPricing.genesis__Enabled_Flag__c = false;
            }
            else{
                activePricingCount = activePricingCount + Portalconstants.ONE_VALUE;
            }
            applicationPricingList.add(individualPricing);
        }        
        Database.update(applicationPricingList,true);
        return activePricingCount;
        
    }

    /**
    * @description updates the certified lenders signature with fsa,cl or c plus
    * @author Rakesh Saraf | 10-23-2024 
    * @param applicationObj 
    * @param loggedInUser 
    **/
    public static void updateCertifiedLendersSignature(genesis__Applications__c applicationObj,User loggedInUser){
        List<clcommon__Relationship__c> dealerRelationsList = new List<clcommon__Relationship__c>();
        List<clcommon__Relationship__c> loggedInUserRelationList = new List<clcommon__Relationship__c>();

        // Querrying the relationship of dealer their relation are CL/CL+/FSA
        dealerRelationsList = [SELECT Id,
                                    clcommon__Related_Entity__c,
                                    clcommon__Related_Entity__r.ParentId,
                                    clcommon__Relationship__r.Name
                                    FROM clcommon__Relationship__c
                                    WHERE clcommon__Entity__c = :loggedInUser.Account.ParentId
                                    AND clcommon__Relationship__r.Name IN (
                                        :PortalConstants.FIELD_STAFF_AGENT,
                                        :PortalConstants.CERTIFIED_LENDER, 
                                        :PortalConstants.CERTIFIED_LENDER_PLUS)];

        for(clcommon__Relationship__c eachRelation: dealerRelationsList){
            //checking whether logged in user has relation with dealer
            if(eachRelation.clcommon__Related_Entity__c == loggedInUser.AccountId){
                loggedInUserRelationList.add(eachRelation);
            }
        }

        //if logged in user doesnt have a relationship with dealer
        PortalApplicationOriginationHelper.checkEmptyList(loggedInUserRelationList, PortalConstants.USER_NOT_AUTHORISED);
        applicationObj.Certified_Lenders_Signature__c = loggedInUserRelationList[0].clcommon__Related_Entity__c;
    }

    /**
    * @description updates the statement code
    * @author Rakesh Saraf | 10-23-2024 
    * @param applicationObj 
    * @param coopType 
    * @param activePricingCount 
    **/
    public static void updateStatementCode(genesis__Applications__c applicationObj,String coopType, Integer activePricingCount){

        PortalApplicationOriginationHelper.checkBlankParameter(coopType, PortalConstants.SOMETHING_WENT_WRONG);
        Integer activeChildLoanCount = 0;

        //we get the number of active child loan using the pricing count on the application
        activeChildLoanCount = activePricingCount;


        Map<String, Statement_Code__mdt> statementCodesMap = StatementCodeHelper.getAllStatementCodeDetails();

        if((String) coopType == PortalConstants.GROWMARK_COOP_TYPE) {
            String monthlyStatementCodeLabel=((String) coopType).toUpperCase() + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX;
            String commitStatementCodeLabel=((String) coopType).toUpperCase() + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX;

            if(activeChildLoanCount == 1 & 
                statementCodesMap.containsKey(monthlyStatementCodeLabel)) {
                    applicationObj.Statement_Code__c = statementCodesMap.get(monthlyStatementCodeLabel).Opt_In_Code__c;
  
            } else {
                if(statementCodesMap.containsKey(commitStatementCodeLabel)) {
                    applicationObj.Statement_Code__c = statementCodesMap.get(commitStatementCodeLabel).Opt_In_Code__c;
                }
            }
        } else {

            //Statement Code for Grey Label:
            //Single Rate --> Partner Program --> Single Rate Opt Out
            //Multi Rate --> Partner Program --> Multi Rate Opt Out

            if(activeChildLoanCount == 1) {
                applicationObj.Statement_Code__c = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Statement_Code_Single_Rate_Opt_Out__c;
  
            } else {
                applicationObj.Statement_Code__c = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Statement_Code_Multi_Rate_Opt_Out__c;
            }
        }
    }

    /**
    * @description returns whether the autobook flag will be true or not.
    * @author Suraj Kumar | 01-31-2024
    * @param borrowerPrincipalIdList 
    * @param isAutoBookPossible 
    * @return Boolean 
    **/
    public static Boolean updateAutobookForNonAccuralLoans(Map<String, List<Id>> dealerBorrowerPartyMap,Boolean isAutoBookPossible){
        if(!isAutoBookPossible){
            return isAutoBookPossible;
        }
        
        //Querying all the Dealer Applicant Relationships for all the borrower and Principal of the given application with the specific Dealer. Check whether any of the
        // applicants have the Non Accrual or Past Due as checked.
        String dealerId = dealerBorrowerPartyMap.get('dealerIdList')[0];
        List<Id> borrowerPrincipalIdList = dealerBorrowerPartyMap.get('borrowerPrincipalIdList');
        List<Dealer_Applicant_Relationship__c> nonAccrualAppPartyList = [SELECT Id
                                                            FROM Dealer_Applicant_Relationship__c 
                                                            WHERE  
                                                            (Is_Non_Accrual__c = True OR Has_Past_Due__c = True)
                                                            AND Dealer__c = :dealerId
                                                            AND Applicant__c IN :borrowerPrincipalIdList];
        
        if(!nonAccrualAppPartyList.isEmpty()){  
            //if there are any applications that is non accrual and the borrower is a part of it, we will not allow autobook
            isAutoBookPossible= false;
        }
        return isAutoBookPossible;
    }

    /**
    * @description Calculate Total Loan Amount of Borrower
    * @author Rakesh Saraf | 10-23-2024 
    * @param currentApplicationList 
    * @return boolean 
    **/
    public static boolean calcBorrowerTotalLoanAmount(List<genesis__Applications__c> currentApplicationList){
        Decimal totalBookingAmount = 0;

        //calculating the total loan amount of all the active and closed applications of the borrwer under the same dealer
        List<AggregateResult> totalLoanAmountList = [SELECT SUM(genesis__Loan_Amount__c) totalLoanAmount 
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Account__c =: currentApplicationList[0].genesis__Account__c 
                                                            AND Dealer_Name__c =: currentApplicationList[0].Dealer_Name__c
                                                            AND (genesis__Status__c IN(:PortalConstants.ACTIVE_APPLICATION_STATUS,:PortalConstants.CLOSED_APPLICATION_STATUS) 
                                                                OR Id =: currentApplicationList[0].id)
                                                            AND Crop_Year__c =: currentApplicationList[0].Crop_Year__c]; 
        totalBookingAmount = Decimal.valueOf(String.valueOf(totalLoanAmountList[0].get(PortalConstants.TOTAL_LOAN_AMOUNT)));

        //if the total loan amount is >1000000, we will not allow autobooking. Hence return false.
        if(totalBookingAmount > Decimal.valueOf(PortalConstants.LOAN_LIMIT_FOR_AUTO_BOOKING)){
            return false;
        }
        return true;
    }

    /**
    * @description insert a note if a note is attached to the application
    * @author Rakesh Saraf | 10-24-2024 
    * @param requestMap 
    * @param applicationObj 
    **/
    public static void updateNote(Map<String, Object> requestMap,genesis__Applications__c applicationObj){
        String noteRecord = PortalConstants.EMPTY_STRING;
        Note noteObj = new Note();
        //if a note is not returned from the portal, we dont update anything
        List<Note> appNoteList =   [SELECT Id,
                                            Title, 
                                            Body, 
                                            ParentId 
                                    FROM Note 
                                    WHERE ParentId = :applicationObj.Id
                                    AND Title = :PortalConstants.DEALER_NOTE_TITLE
                                    LIMIT 1];
        if(requestMap.get(PortalConstants.KEY_NOTE) == null){
            Database.delete(appNoteList,true);
            return;
        }
        noteRecord = String.valueOf(requestMap.get(PortalConstants.KEY_NOTE));
        //if a note has been sent and a note already exists, we change the body of the note
        if(!String.isBlank(noteRecord) & 
            appNoteList.size() == 1) {
                noteObj = appNoteList[0];
                noteObj.Body = noteRecord;

        // if there is no note that aleady exists, we create a new dealer note with the body of the note sent by the CL.
        } else if(!String.isBlank(noteRecord) & 
                    appNoteList.size() != 1) {

            noteObj.Title = PortalConstants.DEALER_NOTE_TITLE;
            noteObj.Body = noteRecord;
            noteObj.ParentId = applicationObj.Id;
        }
        Database.upsert(noteObj, true);

    }

    /**
    * @description update the details that we get from the portal to the application that is queried
    * @author Rakesh Saraf | 11-12-2024 
    * @param currentApplicationList 
    * @param applicationObj 
    **/
    public static void updateQueriedApplicationFields(List<genesis__Applications__c> currentApplicationList,genesis__Applications__c applicationObj){
        //we need to check for this and throw and exception as an application cannot be processed if flex rate pricing is null.
        if(applicationObj.Flex_Rate_Pricing__c==null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        currentApplicationList[0].Flex_Rate_Pricing__c=applicationObj.Flex_Rate_Pricing__c;
        

        //this function updates the fields for the queried application that does not contain the values of these fields as they are retuned in the Score and Credit Agreement Page.

        currentApplicationList[0].Years_Of_Business_With_Applicant__c=applicationObj.Years_Of_Business_With_Applicant__c;
        currentApplicationList[0].Sales_Agent__c=applicationObj.Sales_Agent__c;
        currentApplicationList[0].Internal_Reference_Code__c=applicationObj.Internal_Reference_Code__c;
        currentApplicationList[0].ERP_Id__c=applicationObj.ERP_Id__c;
        currentApplicationList[0].My_Program__c=applicationObj.My_Program__c;
        currentApplicationList[0].Unique_Identifier__c=applicationObj.Unique_Identifier__c;

        currentApplicationList[0].Credit_Application_And_Agreement_Process__c=applicationObj.Credit_Application_And_Agreement_Process__c;

        currentApplicationList[0].Do_You_Recommend_This_Applicant__c=applicationObj.Do_You_Recommend_This_Applicant__c;
        if(applicationObj.Do_You_Recommend_This_Applicant__c == PortalConstants.NEGATIVE_STRING){
            currentApplicationList[0].Lien_Options__c=PortalConstants.EMPTY_STRING;
            assignDefaultCreditRefInfo(currentApplicationList[0]);
            return;
        }


        if(applicationObj.Credit_Application_And_Agreement_Process__c!=PortalConstants.CUSTOMIZE_LOAN){
            currentApplicationList[0].Lien_Options__c=PortalConstants.EMPTY_STRING;
            assignDefaultCreditRefInfo(currentApplicationList[0]);
        }
        else if(applicationObj.Credit_Application_And_Agreement_Process__c==PortalConstants.CUSTOMIZE_LOAN &
                    applicationObj.Lien_Options__c==PortalConstants.UNSECURED_LIEN){
                        currentApplicationList[0].Lien_Options__c=applicationObj.Lien_Options__c;
                        assignDefaultCreditRefInfo(currentApplicationList[0]);
        }
        else if(applicationObj.Credit_Application_And_Agreement_Process__c==PortalConstants.CUSTOMIZE_LOAN &
                    applicationObj.Lien_Options__c!=PortalConstants.UNSECURED_LIEN){

                        currentApplicationList[0].Lien_Options__c=applicationObj.Lien_Options__c;
                        currentApplicationList[0].Lien_Position__c=applicationObj.Lien_Position__c;
                        if(applicationObj.Lien_Position__c==PortalConstants.CROPS_LIEN_POSITION){
                            currentApplicationList[0].Blanket_Lien__c=PortalConstants.EMPTY_STRING;
                            currentApplicationList[0].Crops_Lien__c=applicationObj.Crops_Lien__c;
                        }
                        else{
                            currentApplicationList[0].Crops_Lien__c=PortalConstants.EMPTY_STRING;
                            currentApplicationList[0].Blanket_Lien__c=applicationObj.Blanket_Lien__c;
                        }

                        currentApplicationList[0].Jointly_Payable_Proceeds_Checks__c=applicationObj.Jointly_Payable_Proceeds_Checks__c;
                        currentApplicationList[0].Assignment_Of_Insurance__c=applicationObj.Assignment_Of_Insurance__c;
                        currentApplicationList[0].Spousal_Consent__c=applicationObj.Spousal_Consent__c;
                        currentApplicationList[0].Other_Additional_Requirements_Needed__c=applicationObj.Other_Additional_Requirements_Needed__c;

                        if(applicationObj.Other_Additional_Requirements_Needed__c==PortalConstants.FALSE_VALUE){
                            currentApplicationList[0].Other_Additional_Requirements__c=PortalConstants.EMPTY_STRING;
                        }
                        else{
                            currentApplicationList[0].Other_Additional_Requirements__c=applicationObj.Other_Additional_Requirements__c;
                        }
        }
    }

    /**
    * @description the purpose of the method is to assign the default values of the Credit Reference Information
    * @author Rakesh Saraf | 11-16-2024 
    * @param currentApplicationObj 
    **/
    private static void assignDefaultCreditRefInfo(genesis__Applications__c currentApplicationObj){
        currentApplicationObj.Lien_Position__c=PortalConstants.EMPTY_STRING;
        currentApplicationObj.Crops_Lien__c=PortalConstants.EMPTY_STRING;
        currentApplicationObj.Blanket_Lien__c=PortalConstants.EMPTY_STRING;
        currentApplicationObj.Jointly_Payable_Proceeds_Checks__c=PortalConstants.FALSE_VALUE;
        currentApplicationObj.Assignment_Of_Insurance__c=PortalConstants.FALSE_VALUE;
        currentApplicationObj.Spousal_Consent__c=PortalConstants.FALSE_VALUE;
        currentApplicationObj.Other_Additional_Requirements_Needed__c=PortalConstants.FALSE_VALUE;
        currentApplicationObj.Other_Additional_Requirements__c=PortalConstants.EMPTY_STRING;
    }


    /**
    * @description get the contact,account and busniess info id of the borrower
    * @author Rakesh Saraf | 11-13-2024 
    * @param currentApplicationObj 
    * @return Map<String, Id> 
    **/
    public static Map<String,Id> getBorrowerDetails(genesis__Applications__c currentApplicationObj){

        Id borrowerAccountId;
        Id borrowerContactId;
        Id borrowerBusinessInfoId;

        for(clcommon__Party__c individualParty:currentApplicationObj.genesis__Parties__r){
        //Check whether Total Assets and Liabilities are present
            PortalApplicationOriginationHelper.checkAssetAndLiability(individualParty);
            

            //returns the borrwer contct, account and busniess info id
            if(individualParty?.clcommon__Type__r?.Name == PortalConstants.BORROWER_PARTY_NAME ){
                borrowerAccountId = individualParty.clcommon__Account__c;
                borrowerContactId = individualParty.clcommon__Contact__c;
                borrowerBusinessInfoId = individualParty.clcommon__Account__r.genesis__Business_information__c;
                
                PortalApplicationOriginationHelper.checkCoApplicant(currentApplicationObj.genesis__Parties__r);
                break;
            }
  
        }
        return (new Map<String,Id>{
                            PortalConstants.ACCOUNT_KEY=>borrowerAccountId,
                            PortalConstants.CONTACT_KEY=>borrowerContactId,
                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>borrowerBusinessInfoId
                        });
    }

    /**
    * @description get the contact, account and business info id of all the parties
    * @author Rakesh Saraf | 11-13-2024 
    * @param currentApplicationObj 
    * @return Map<String, List<Id>> 
    **/
    public static Map<String,List<Id>> getPrincipalDetails(genesis__Applications__c currentApplicationObj){
        List<Id> principalAccountIdList=new List<Id>();
        List<Id> principalContactIdList=new List<Id>();
        List<Id> principalBInfoIdList=new List<Id>();

        for(clcommon__Party__c individualParty:currentApplicationObj.genesis__Parties__r){
            //Check whether Total Assets and Liabilities are present
            PortalApplicationOriginationHelper.checkAssetAndLiability(individualParty);
                
    
            //returns the borrwer contct, account and busniess info id
            if(individualParty?.clcommon__Type__r?.Name != PortalConstants.BORROWER_PARTY_NAME ){

            //     //we add the account, contact and business info id for the principls in a list
                principalAccountIdList.add(individualParty.clcommon__Account__c);
                principalContactIdList.add(individualParty.clcommon__Contact__c);
                principalBInfoIdList.add(individualParty.clcommon__Account__r.genesis__Business_information__c); 
            }
      
        }
        return (new Map<String,List<Id>>{
                                    PortalConstants.ACCOUNT_KEY=>principalAccountIdList,
                                    PortalConstants.CONTACT_KEY=>principalContactIdList,
                                    PortalConstants.BUSINESS_INFO_OBJ_KEY=>principalBInfoIdList
                                });

    }

    
    /**
    * @description return autobook flag according to the gurantee, loan customization or total loan limit
    * @author Kabir Pramanik | 12-26-2024 
    * @param currentApplicationList 
    * @param isAutoBookPossible 
    * @return Boolean 
    **/
    public static Boolean checkIsAutobookPossible(List<genesis__Applications__c> currentApplicationList, Boolean isAutoBookPossible){
        //isAutoBookPossible will get updated based on the Guarantee on the application 
        //check if the sum of loan amount of all the active and closed loans plus the loan amount of this application does not exceed the loan limit for autobooking
        if(currentApplicationList[0].Guarantee__c == Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_4) | 
            currentApplicationList[0].Credit_Application_And_Agreement_Process__c == PortalConstants.CUSTOMIZE_LOAN |
            !PortalApplicationSubmissionHandler.calcBorrowerTotalLoanAmount(currentApplicationList)){
                isAutoBookPossible =  PortalConstants.FALSE_VALUE;
        }
        return isAutoBookPossible;
    }
}