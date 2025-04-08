/**
 * @description       : Move non accrual loans to accrual from skuid.
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 04-04-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   17-01-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSMoveLoanToAccrual {
    
    private static final String NINE = '9';
    private static final String DASH = '-';
    private static final String SPECIAL_TERM_SUB_TRANCHE_LEFT = 'Special Term Sub-Tranche (';
    private static final String SPECIAL_TERM_SUB_TRANCHE_RIGHT = ')';

    /**
    * @description : This method checks access on different objects
    * @author Tuhin Bhunia | 05-12-2024 
    **/
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Application_Pricing_Detail__c.isAccessible())
                | (!Schema.sObjectType.clcommon__Party__c.isAccessible())
                | (!Schema.sObjectType.genesis__Applications__c.isAccessible())
                | (!Schema.sObjectType.Dealer_Applicant_Relationship__c.isAccessible())
                | (!Schema.sObjectType.genesis__Applications__c.isUpdateable())
                | (!Schema.sObjectType.genesis__Application_Pricing_Detail__c.isUpdateable())
                | (!Schema.sObjectType.Dealer_Applicant_Relationship__c.isUpdateable())
                | (!Schema.sObjectType.genesis__Application_Pricing_Detail__c.isUpdateable())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }

    /**
    * @description : This method moves the loan from nonaccrual to accrual
    * @author Suraj Kumar | 02-05-2024 
    * @param applicationId 
    * @return String 
    **/
    webservice static String moveToAccrual(String applicationId) {
        //Mark the loan as Accrual
        //Change the loan number, remove 9 from all loan, child loans
        //Fetch Loan id from the new loan number
        List<genesis__Application_Pricing_Detail__c> childLoanList = new List<genesis__Application_Pricing_Detail__c>();
        checkAccessOnObjects();
        try {
            Date today = System.today();
            List<genesis__Applications__c> applicationList = getApplicationList(applicationId);
            //mark the loan as Accrual
            applicationList[0].Non_Accrual__c = false;
            //Remove 9 from the loan number
            if(String.valueOf(applicationList[0].genesis__Loan_Number__c).substring(0,1) == NINE){
                applicationList[0].genesis__Loan_Number__c = String.valueOf(applicationList[0].genesis__Loan_Number__c).substring(1);
            }

            for(genesis__Application_Pricing_Detail__c childLoanObj : applicationList[0].genesis__Pricing_Details__r){
                if(childLoanObj.Loan_Number__c != null){
                    String tempChildLoanNumber = childLoanObj.Loan_Number__c;
                    if(String.valueOf(childLoanObj.Loan_Number__c).substring(0,1)== NINE){
                        assignChildLoanNumber(tempChildLoanNumber, childLoanObj);
                    }
                    
                    if(today >= childLoanObj.genesis__Rate_Card_Setup_Detail__r.Start_Date__c && today < childLoanObj.genesis__Rate_Card_Setup_Detail__r.End_Date__c ){
                        childLoanObj.genesis__Enabled_Flag__c = true;
                    }else{
                        childLoanObj.genesis__Enabled_Flag__c = false;
                    }
                }
                childLoanList.add(childLoanObj);
            }

            Database.update(applicationList,true);
            Database.update(childLoanList,true);
            //updating Non accrual to false on borrower and princial account if they are not associated with any non accrual loan in our system
            updateNonAccrualOnAccount(applicationList[0].Id);

            //Fetch the Loan Id for parent and child loans
            System.enqueueJob(new FetchLoanIdQueueable( applicationList[0].genesis__Loan_Number__c, applicationList[0].Id, true));

        } 
        catch (Exception exceptionObj) {
            LoggingUtility.saveExceptionLogging(exceptionObj, NLSMoveLoanToAccrual.class.getName());
            return exceptionObj.getMessage();
        } 
        return ConstantValues.SUCCESS_STATUS;
        
    }

    /**
    * @description : updating Non accrual to false on borrower and princial account if they are not associated with any non accrual loan in our system
    * @author Suraj Kumar | 02-05-2024 
    * @param applicationId 
    **/
    private static void updateNonAccrualOnAccount(String applicationId){
        //querrying the borrower and principal party of application and adding their account id in List
        checkAccessOnObjects();
        List<Id> partyDealerAppIdList = new List<Id>();
        Set<Id> nonAccrualAccountIdSet = new Set<Id>();
        List<Dealer_Applicant_Relationship__c> dealerAppRelToUpdateList = new List<Dealer_Applicant_Relationship__c>();

        List<clcommon__Party__c> partyObjList = [SELECT Id,
                                                            Dealer_Applicant_Relationship__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Party_Types__c IN (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) 
                                                AND genesis__Application__c = :applicationId];
        for(clcommon__Party__c partyObj: partyObjList){
            partyDealerAppIdList.add(partyObj.Dealer_Applicant_Relationship__c);
        }

        //querry the borrower and principal party of current application which is associated with any other non-accrual application
        List<clcommon__Party__c> nonAccrualAppPartyList = [SELECT Id,
                                                                    Dealer_Applicant_Relationship__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE clcommon__Party_Types__c IN (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) 
                                                            AND genesis__Application__r.Non_Accrual__c = True
                                                            AND Dealer_Applicant_Relationship__c IN :partyDealerAppIdList];
        for(clcommon__Party__c nonAccrualPartyObj: nonAccrualAppPartyList){
            nonAccrualAccountIdSet.add(nonAccrualPartyObj.Dealer_Applicant_Relationship__c);
        }

        // adding the account id of borrower and principal of application which is not associated with any non accrual aplication
        for(Id dealerApplicantId: partyDealerAppIdList){
            if(!nonAccrualAccountIdSet.contains(dealerApplicantId)){
                Dealer_Applicant_Relationship__c newdealerRelObj = new Dealer_Applicant_Relationship__c(
                Id = dealerApplicantId,
                Is_Non_Accrual__c = false
                );
                dealerAppRelToUpdateList.add(newdealerRelObj);
            }
        }
        Database.update(dealerAppRelToUpdateList,true);

    }

    /**
     * @description Geeting the application in a list
     * @param applicationId 
     * @return  `List<genesis__Applications__c>`
     * @exception 
     */
    private static List<genesis__Applications__c> getApplicationList(String applicationId){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Non_Accrual__c,
                                                                    genesis__Loan_Number__c,
                                                                    Loan_Id__c,
                                                                                (SELECT Id, 
                                                                                        loan_Number__c,
                                                                                        genesis__Application__r.Non_Accrual__c,
                                                                                        genesis__Enabled_Flag__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.Special_Term_Order__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.Start_Date__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.End_Date__c
                                                                                FROM genesis__Pricing_Details__r)
                                                            FROM genesis__Applications__c
                                                            WHERE Id = :applicationId];

        CFAOriginationHelperClass.checkEmptyList(applicationList, ConstantValues.SOMETHING_WENT_WRONG);
        return applicationList;
    }

    /**
    * @description : Purpose of this method to assign Child Loan Numbers while moving a non-accrual loan to accrual
    * @author Tuhin Bhunia | 05-02-2024 
    * @param tempChildLoanNumber 
    * @param childLoanObj 
    **/
    private static void assignChildLoanNumber(String tempChildLoanNumber, genesis__Application_Pricing_Detail__c childLoanObj){
            childLoanObj.Loan_Number__c = tempChildLoanNumber.substring(1) + DASH + String.valueOf(childLoanObj.genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c).substringBetween(SPECIAL_TERM_SUB_TRANCHE_LEFT,SPECIAL_TERM_SUB_TRANCHE_RIGHT);
    }
}