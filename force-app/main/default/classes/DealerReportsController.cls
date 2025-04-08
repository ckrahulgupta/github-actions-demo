/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 12-27-2024
 * @last modified by  : Rahul Gupta
**/
global without sharing class DealerReportsController {
    
    public class ReportDetail {

        public String workspaceId {get; set;}
        public String reportId {get; set;}

        public String coopTypeTable {get; set;}
        public String coopTypeField {get; set;}

        public String dealerTable {get; set;}
        public String dealerField {get; set;}

        public String dealerCIF {get; set;}
        public String dealerCoopType {get; set;}

        public String reportName {get; set;}

    }

    public ReportDetail reportData {get; set;}


    /**
    * @description 
    * @author Rahul Gupta | 12-27-2024 
    **/
    public DealerReportsController() {

        String reportName = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('reportName'));

        List<Dealer_Embedded_Report__mdt> reportMetaDataList = [
            SELECT Id,
                    DeveloperName,
                    Label,
                    Workspace_Id__c,
                    Report_Id__c,
                    Coop_Type_Table__c,
                    Coop_Type_Field__c,
                    Dealer_Table__c,
                    Dealer_Field__c
            FROM Dealer_Embedded_Report__mdt
            WHERE DeveloperName = :reportName

            WITH SECURITY_ENFORCED
            LIMIT 1

        ];

        List<User> loggedInUser = [
            SELECT Id, 
                Account.Parent.CIF_Number__c, 
                Account.Parent.Coop_Type__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            
            WITH SECURITY_ENFORCED

            LIMIT 1
        ];

        if (loggedInUser.size() == 0 || 
            loggedInUser[0].Account.Parent.CIF_Number__c == null || 
            loggedInUser[0].Account.Parent.Coop_Type__c == null || 
            reportMetaDataList.size() == 0) {

            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        ReportDetail reportData = new ReportDetail();
        reportData.workspaceId = reportMetaDataList[0].Workspace_Id__c;
        reportData.reportId = reportMetaDataList[0].Report_Id__c;
        reportData.coopTypeTable = reportMetaDataList[0].Coop_Type_Table__c;
        reportData.coopTypeField = reportMetaDataList[0].Coop_Type_Field__c;
        reportData.dealerTable = reportMetaDataList[0].Dealer_Table__c;
        reportData.dealerField = reportMetaDataList[0].Dealer_Field__c;
        reportData.dealerCIF = loggedInUser[0].Account.Parent.CIF_Number__c;
        reportData.dealerCoopType = loggedInUser[0].Account.Parent.Coop_Type__c.toUpperCase();
        reportData.reportName = reportName;

        this.reportData = reportData;
    }
}