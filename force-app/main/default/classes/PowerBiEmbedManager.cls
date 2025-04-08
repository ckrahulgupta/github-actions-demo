/**
 * Created by Riadh Mankai on 12/3/24.
 * @description This class is responsible for embedding Power BI reports in Salesforce using Power BI REST APIs.
 */
global without sharing class PowerBiEmbedManager {

	public class ClientCredentialPostData {
		public String client_id;
		public String client_info;
		public String client_secret;
		public String scope;
		public String grant_type;
		public String getPostData() {
			return 'client_id=' + this.client_id +
				  '&client_info=' + this.client_info +
				  '&client_secret=' + this.client_secret +
				  '&scope=' + this.scope +
				  '&grant_type=' + grant_type;
		}
	}

	public class ClientCredentialResponse {
		public String access_token;
		public String expires_in;
		public String token_type;
	}

	public class PowerBiReport {
		public String id { get; set; }
		public String reportType { get; set; }
		public String name { get; set; }
		public String embedUrl { get; set; }
		public String datasetId { get; set; }
	}

	public class PowerBiEmbedToken {
		public String token { get; set; }
		public String tokenId { get; set; }
		public Datetime expiration { get; set; }
	}

	public class PowerBiReportData {
		@AuraEnabled
		public String workspaceId { get; set; }
		@AuraEnabled
		public String reportId { get; set; }

		@AuraEnabled
		public String uniqueIdTable { get; set; }

		@AuraEnabled
		public String uniqueIdField { get; set; }
		

		@AuraEnabled
		public String uniqueIdValues { get; set; }

		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String embedUrl { get; set; }
		@AuraEnabled
		public String embedToken { get; set; }
		@AuraEnabled
		public Datetime embedTokenExpires { get; set; }
		@AuraEnabled
		public String error { get; set; }
	}

	public static String getPowerBiAccessToken() {
		// get auth settings from Custom Metadata Type reconrd
		Power_BI_Auth_Setting__mdt authSetting = Power_BI_Auth_Setting__mdt.getInstance('Power_BI_Auth_Setting');
		
		String TenantId = authSetting.TenantId__c;
		String ClientId = authSetting.ClientId__c;
		String ClientSecret = authSetting.ClientSecret__c;

		// construct URL for client credentials flow
		String aadTokenEndpoint = 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';

		// prepare HTTP request
		HttpRequest reqClientCredentialsFlow = new HttpRequest();
		reqClientCredentialsFlow.setMethod('POST');
		reqClientCredentialsFlow.setEndpoint(aadTokenEndpoint);
		reqClientCredentialsFlow.setHeader('Content-Type', 'application/x-www-form-urlencoded');

		// compose data for POST body
		ClientCredentialPostData postData = new ClientCredentialPostData();
		postData.client_id = ClientId;
		postData.client_info = '1';
		postData.client_secret = ClientSecret;
		postData.scope = 'https://analysis.windows.net/powerbi/api/.default';
		postData.grant_type = 'client_credentials';
		String postBody = postData.getPostData();
		reqClientCredentialsFlow.setBody(postBody);

		// send HTTP POST to execute client credentials flow
		Http http = new Http();
		HttpResponse response = http.send(reqClientCredentialsFlow);

		// extract and return app-only access token for service principal
		String responseJson = response.getBody();
		ClientCredentialResponse responseData = (ClientCredentialResponse) JSON.deserialize(responseJson, ClientCredentialResponse.class);
		String access_token = responseData.access_token;
		return access_token;
	}

	@AuraEnabled(Cacheable = true)
	public static PowerBiReportData getEmbeddingDataForReport(String reportName) {

		if (reportName == null) {
			throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
		}

		List<Dealer_Embedded_Report__mdt> reportMetaDataList = [
            SELECT Id,
                    DeveloperName,
                    Label,
                    Workspace_Id__c,
                    Report_Id__c,
                    Coop_Type_Table__c,
                    Coop_Type_Field__c,
                    Dealer_Table__c,
                    Dealer_Field__c,
					Unique_Id_Table__c,
					Unique_Id_Field__c
            FROM Dealer_Embedded_Report__mdt
            WHERE DeveloperName = :reportName
            LIMIT 1
        ];
        List<User> loggedInUser = [
            SELECT Id, 
                Account.Parent.CIF_Number__c, 
                Account.Parent.Coop_Type__c,
				Account.Parent.Unique_Id__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        

            LIMIT 1
        ];
		if (loggedInUser.size() == 0 || 
            loggedInUser[0].Account.Parent.Unique_Id__c == null ||
            reportMetaDataList.size() == 0) {

            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }



		// get access token for Authorization header
		String access_token = getPowerBiAccessToken();

		// Call to Power BI Service API to get report data for embedding
		HttpRequest reqGetReport = new HttpRequest();
		reqGetReport.setMethod('GET');
		String urlGetReport = 'https://api.powerbi.com/v1.0/myorg/groups/' + reportMetaDataList[0].Workspace_Id__c + '/reports/' + reportMetaDataList[0].Report_Id__c;
		reqGetReport.setEndpoint(urlGetReport);
		reqGetReport.setHeader('Authorization', 'Bearer ' + access_token);

		Http http = new Http();
		HttpResponse response = http.send(reqGetReport);

		// check response for success
		if (response.getStatusCode() != 200) {
			System.debug('ERROR --- Getting Report Data --- ERROR');
			System.debug('Status Code: ' + response.getStatusCode());
			PowerBiReportData getReportError = new PowerBiReportData();
			getReportError.error = 'Get Report Error: ' + response.getStatus();
			return getReportError;
		}

		// extract Power BI report data from JSON response
		String responseJson = response.getBody();
		PowerBiReport powerBiReport = (PowerBiReport) JSON.deserialize(responseJson, PowerBiReport.class);


		// Call to Power BI Service API to get embed token for report
		HttpRequest reqGetEmbedToken = new HttpRequest();
		reqGetEmbedToken.setMethod('POST');
		String urlGetEmbedToken = 'https://api.powerbi.com/v1.0/myorg/groups/' + reportMetaDataList[0].Workspace_Id__c + '/reports/' + reportMetaDataList[0].Report_Id__c + '/GenerateToken';
		reqGetEmbedToken.setEndpoint(urlGetEmbedToken);
		reqGetEmbedToken.setHeader('Authorization', 'Bearer ' + access_token);
		reqGetEmbedToken.setBody('{"accessLevel": "View", "datasetId": "' + powerBiReport.datasetId + '"}');

		HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);

		// check response for success
		if (responseEmbedToken.getStatusCode() != 200) {
			System.debug('ERROR --- Getting Embed Token --- ERROR');
			System.debug('Status Code: ' + responseEmbedToken.getStatusCode());
			PowerBiReportData getEmbedTokenError = new PowerBiReportData();
			getEmbedTokenError.error = 'Get Embed Token Error: ' + response.getStatus();
			return getEmbedTokenError;
		}

		// extract Power BI embed token and expiration
		PowerBiEmbedToken embedToken = (PowerBiEmbedToken) JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);

		// create custom remote-able object to return to caller in browser
		PowerBiReportData powerBiReportData = new PowerBiReportData();
		powerBiReportData.workspaceId = reportMetaDataList[0].Workspace_Id__c;
		powerBiReportData.reportId = reportMetaDataList[0].Report_Id__c;

		powerBiReportData.uniqueIdTable = reportMetaDataList[0].Unique_Id_Table__c;
		powerBiReportData.uniqueIdField = reportMetaDataList[0].Unique_Id_Field__c;
		powerBiReportData.uniqueIdValues = loggedInUser[0].Account.Parent.Unique_Id__c;

		powerBiReportData.name = powerBiReport.name;
		powerBiReportData.embedUrl = powerBiReport.embedUrl;
		powerBiReportData.embedToken = embedToken.token;
		powerBiReportData.embedTokenExpires = embedToken.expiration;

		return powerBiReportData;
	}
}