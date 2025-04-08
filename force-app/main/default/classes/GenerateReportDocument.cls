global without sharing class GenerateReportDocument {

    private static final String GENERATE_REPORT_DOCUMENT = 'GenerateReportDocument';

    private static void runReport(Id reportId) {
        Reports.ReportResults reportResults = Reports.ReportManager.runReport(reportId, true);
    }


    private static Blob getReportContent(Id reportId) {
        return (new ApexPages.PageReference('/' 
                                            + reportId 
                                            + '?export=Export&enc=UTF-8&xf=xls&isdtp=p1'))
                .getContent();
        // return (new ApexPages.PageReference('/servlet/PrintableViewDownloadServlet?reportId=' 
        //                                     + reportId 
        //                                     + '&export=Export&enc=UTF-8&xf=xls&isdtp=p1&deletefilter=true&deleteObjfilter=true'))
        //         .getContent();
    }

    private static void setDateTimeFilter(Id reportId) {
        
    }

    public static void createDocument(Id reportId, Id folderId) {
        try {

            List<Report> reportList = [SELECT Id, 
                                              Name 
                                       FROM Report 
                                       WHERE Id = :reportId 
                                       LIMIT 1];
            
            List<Folder> folderList = [SELECT Id, 
                                              Name 
                                       FROM Folder 
                                       WHERE Id = :folderId 
                                       LIMIT 1];
            
            if (reportList.size() == 0) {
                throw new CustomException('No report found with the given ID.');
            }

            if (folderList.size() == 0) {
                throw new CustomException('No folder found with the given ID.');
            }

            runReport(reportId);
        
            Document document = new Document();
            document.Body = getReportContent(reportId);
            document.IsPublic = true;
            document.Name = reportList[0].Name + ' - ' + Datetime.now() + '.xls';
            document.FolderId = folderId;

            Database.insert(document);

        } catch (CustomException objCustomException) {
            // handle exception
            PortalHelper.saveExceptionLog(objCustomException, GENERATE_REPORT_DOCUMENT);
        } catch (Exception objException) {
            // handle exception
            PortalHelper.saveExceptionLog(objException, GENERATE_REPORT_DOCUMENT);
        }
    }
}