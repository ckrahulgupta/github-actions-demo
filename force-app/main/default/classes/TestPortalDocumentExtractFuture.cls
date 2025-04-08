/**
 * @description       : Extract portal document asynchronously
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 20-07-2022
 * @last modified by  : Rahul Gupta
**/
@IsTest
public class TestPortalDocumentExtractFuture {

   
    @TestSetup
    static void makeData() {

        Document document = new Document();
        document.Body = Blob.valueOf('{"clcommon__Actors__c":[{"attributes":{"type":"clcommon__Actors__c","url":"/services/data/v55.0/sobjects/clcommon__Actors__c/a0M76000000GxqHEAS"},"clcommon__Actor_Name__c":"growerResetPasswordForm","clcommon__Actor_Definition__c":"{\"generalHandlers\":{},\"recordActions\":[],\"componentActions\":[],\"appearance\":{\"showSectionTitle\":true,\"grid\":{\"field\":{\"confirmPassword\":{\"md\":12},\"password\":{\"md\":12}}},\"subTitle\":\"<h1 class=\\\"heading heading-secondary heading--underline-center u-text-center u-color-primary u-py-sm\\\"> Set Password </h1>\",\"sectionStyle\":\"layout\",\"expansionBottom\":\"large\",\"expansionTop\":\"large\",\"title\":\" <center><img src=\\\"/resource/growerPortalLogo\\\" alt=\\\"CFA Logo\\\"> </center>\",\"fieldColumns\":1,\"editable\":true},\"property\":{\"structureName\":\"portal_grower_reset_password\"},\"type\":\"detail-view\",\"category\":\"component\"}","clcommon__Navigation_Structure__c":"a2h760000008UMwAAM","Id":"a0M76000000GxqHEAS","clcommon__Navigation_Structure__r":{"attributes":{"type":"clcommon__NavigationStructure__c","url":"/services/data/v55.0/sobjects/clcommon__NavigationStructure__c/a2h760000008UMwAAM"},"Name":"portal_grower_reset_password","Id":"a2h760000008UMwAAM"}}],}');

        document.ContentType = 'text/plain';
        document.DeveloperName = 'portal_document';
        document.IsPublic = true;
        document.Name = 'portal_document';
        document.FolderId = [select id from folder where name = 'CL Portal'].id;
        insert document;

    }

    @IsTest
    public static void testCase1() {

        Document objPortalDocument = [select id from Document where name = 'portal_document'];

        PortalDocumentExtractFuture.processRecords(new List<String>{(String) objPortalDocument.Id});
    }
}