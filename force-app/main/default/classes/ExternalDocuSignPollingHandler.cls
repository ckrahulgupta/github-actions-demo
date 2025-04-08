/**
 * @description       : Handler class for ExternalDocuSignPollingAPI
 * @author            : Suraj Kumar | 06-19-2024
 * @group             : 
 * @last modified on  : 06-20-2024
 * @last modified by  : Suraj Kumar
**/
public inherited sharing class ExternalDocuSignPollingHandler {
    /**
    * @description : method to get applicant party for docusign
    * @author Suraj Kumar | 06-19-2024 
    * @param applicationObj 
    * @return List<clcommon__party__c> 
    **/
    public static List<clcommon__party__c> getApplicantParty(genesis__Applications__c applicationObj){
        List<clcommon__party__c> applicantPartyList = new List<clcommon__party__c>();
        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name == ExternalConstants.SOLE_PROP_ENTITY){
            applicantPartyList =  [SELECT Id,
                                            clcommon__Account__r.Name,
                                            DocuSign_URL__c,
                                            Sent_Url__c,
                                            clcommon__Contact__c,
                                            DocuSign_Generation_Time__c,
                                            DocuSign_Signing_Status__c 
                                        FROM clcommon__Party__c
                                        WHERE genesis__Application__r.Id=:applicationObj.Id 
                                        AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        }
        else{
            applicantPartyList =  [SELECT Id,
                                            clcommon__Account__r.Name,
                                            DocuSign_URL__c,
                                            Sent_Url__c,
                                            clcommon__Contact__c,
                                            DocuSign_Generation_Time__c,
                                            DocuSign_Signing_Status__c 
                                        FROM clcommon__Party__c
                                        WHERE genesis__Application__r.Id=:applicationObj.Id 
                                        AND clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY 
                                        AND Principal_Number__c = 1];
        }
        if(applicantPartyList.size() != 1){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.APPLICANT_INVALID);
        }
        return applicantPartyList;
    }

    /**
    * @description : method to check application status for docusign
    * @author Suraj Kumar | 06-19-2024 
    * @param applicationObj 
    **/
    public static void checkAppStatus(genesis__Applications__c applicationObj){
        if(applicationObj.genesis__Status__c != ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS){
            ExternalAdditionalInformationHandler.throwCustomException(ExternalConstants.APP_STATUS_INVALID);
        }
    }

    /**
    * @description : method to get Url time of docusign link
    * @author Suraj Kumar | 06-19-2024 
    * @param applicantPartyList 
    * @return Decimal 
    **/
    public static Decimal getUrlTime(List<clcommon__party__c> applicantPartyList){
        Decimal urlTime = 0.0;
        if(applicantPartyList[0].DocuSign_Generation_Time__c !=null){
            urlTime = Decimal.valueOf((System.now().getTime()- applicantPartyList[0].DocuSign_Generation_Time__c.getTime())/(1000*60));
        }
        return urlTime;
    }
}