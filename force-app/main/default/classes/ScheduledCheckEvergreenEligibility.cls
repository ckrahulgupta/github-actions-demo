/**
 * @description       : This Schedulable class will run yearly and check which all applications are evergreen eligible for the upcoming Crop year
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Suraj Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-05-2023   Subham Nandi   Initial Version
**/
global with sharing class ScheduledCheckEvergreenEligibility implements Schedulable {
    //Class Specific Constants ----------------------------------------------------------------------
    private static final String CLASS_NAME = 'ScheduledCheckEvergreenEligibility';
    private final static String IN_PERSON_DOCUSIGN = 'In Person - Docusign';
    private final static String EMAIL_DOCUSIGN = 'Email - Docusign';
    private final static String NO_APPLICATION_FOUND = 'There are no Application to Mark Evergreen Eligible';
    //Class Specific Constants ----------------------------------------------------------------------

     /**
    * @description : this method is used to Mark the Loan as Evergreen Eligible, so that it can be cloned for the next crop year loan.
    * @author Suraj Kumar | 03-12-2024 
    * @param sc 
    **/
    global void execute(SchedulableContext sc){
        try {
            //Query all the Current Crop Year Active Loans
            List<genesis__Applications__c> objApplicationList = [SELECT Id,
                                                                        Is_Evergreen_Eligible__c
                                                                FROM genesis__Applications__c
                                                                WHERE genesis__Status__c = :ConstantValues.ACTIVE AND 
                                                                Crop_Year__c = :String.valueOf(System.today().Year()) AND 
                                                                genesis__Credit_Rating__r.Name IN (:ConstantValues.CREDIT_RATE_1, :ConstantValues.CREDIT_RATE_2) AND 
                                                                Non_Accrual__c = false AND 
                                                                Signing_Method__c IN (:IN_PERSON_DOCUSIGN, :EMAIL_DOCUSIGN)];
            if(objApplicationList.size() > 0){
                for(genesis__Applications__c eachCurrentApplication : objApplicationList){
                    //Marking the Loan as Evergreen Eligible, so that it can be cloned for the next crop year loan
                    eachCurrentApplication.Is_Evergreen_Eligible__c = true;
                }
                Database.update(objApplicationList,true);
            }
            else{
                throw new CustomException (NO_APPLICATION_FOUND);
            }

        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
}