/**
 * Created by Riadh Mankai on 12/2/24.
 * @description This class is responsible for testubg tge embedding Power BI reports in Salesforce using Power BI REST APIs.
 * @see PowerBiEmbedManager
 */

@IsTest
public class PowerBiEmbedManagerTest {
	static final String EXPECTED_ACCESS_TOKEN = 'mock_access_token';
	static final String EXPECTED_EMBED_TOKEN = 'mock_embed_token';
	static final String EXPECTED_REPORT_NAME = 'Past_Due_Report';
	static final String EXPECTED_REPORT_ID = 'mock_report_id';
	static final String EXPECTED_WORKSPACE_ID = 'mock_workspace_id';
	static final String EXPECTED_MOCK_URL = 'https://mock.embed.url';
	static final String EXPECTED_MOCK_REPORT = 'Mock Report';

	@TestSetup
	static void makeData(){
		ApplicationOriginationSetupTestHelper.createTestSetup();

	}

	@IsTest
	static void testGetPowerBiAccessToken() {
		
		System.runAs([SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'][0]) {
			Test.startTest();

			// Set mock callout
			Test.setMock(HttpCalloutMock.class, new PowerBiEmbedManagerMock());

			// Call the method to test
			String accessToken = PowerBiEmbedManager.getPowerBiAccessToken();

			// Verify the result
			System.assertEquals(EXPECTED_ACCESS_TOKEN, accessToken);

			Test.stopTest();
		}
		
	}
	
	
	
    /**
	* @description 
	* @author Rahul Gorai | 01-28-2025 
	**/
	@IsTest
	static void testGetEmbeddingDataForReport() {
        
        List<User> userList=[SELECT Id,Account.ParentId, ContactId FROM User WHERE Username = 'ross.geller@yopmail.com'];
		List<Account> dealerAccountList=   [SELECT Id, Name, Unique_Id__c
											FROM Account 
											WHERE  Id =: userList[0].Account.ParentId];	
		dealerAccountList[0].Unique_Id__c='145256aeds-sdfg345-fsf3563';
		Database.update(dealerAccountList[0],true);
		System.runAs(userList[0]) {

			Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PowerBiEmbedManagerMock());
            PowerBiEmbedManager.PowerBiReportData reportData = PowerBiEmbedManager.getEmbeddingDataForReport(EXPECTED_REPORT_NAME);
            System.assertEquals(EXPECTED_MOCK_REPORT, reportData.name);
			System.assertEquals(EXPECTED_MOCK_URL, reportData.embedUrl);
			System.assertEquals(EXPECTED_EMBED_TOKEN, reportData.embedToken);
			System.assertNotEquals(null, reportData.embedTokenExpires);
			System.assertEquals(null, reportData.error);

			Test.stopTest();

		}
		
	}
	/**
	* @description 
	* @author Rahul Gorai | 01-28-2025 
	**/
	@IsTest
	static void testGetEmbeddingDataForNullUniqueReport() {
        
        List<User> userList=[SELECT Id,Account.ParentId, ContactId FROM User WHERE Username = 'ross.geller@yopmail.com'];
		List<Account> dealerAccountList=   [SELECT Id, Name, Unique_Id__c
											FROM Account 
											WHERE  Id =: userList[0].Account.ParentId];	
		dealerAccountList[0].Unique_Id__c=null;
		Database.update(dealerAccountList[0],true);
		Boolean flag = false;
		try {
			System.runAs(userList[0]) {
				Test.startTest();
				Test.setMock(HttpCalloutMock.class, new PowerBiEmbedManagerMock());
				PowerBiEmbedManager.PowerBiReportData reportData = PowerBiEmbedManager.getEmbeddingDataForReport(EXPECTED_REPORT_NAME);
	
				System.assertEquals(EXPECTED_MOCK_REPORT, reportData.name);
				System.assertEquals(EXPECTED_MOCK_URL, reportData.embedUrl);
				System.assertEquals(EXPECTED_EMBED_TOKEN, reportData.embedToken);
				System.assertNotEquals(null, reportData.embedTokenExpires);
				System.assertEquals(null, reportData.error);
	
				Test.stopTest();
	
			}
		} catch (Exception exceptionObj) {
			flag =true;
		}  
		System.assertEquals(true,flag,'Exception not ocured');
		
	}
	/**
	* @description 
	* @author Rahul Gorai | 01-28-2025 
	**/
    @IsTest
	static void testGetEmbeddingDataForNullReport() {
        
        List<User> userList=[SELECT Id,Account.ParentId, ContactId FROM User WHERE Username = 'ross.geller@yopmail.com'];
		List<Account> dealerAccountList=   [SELECT Id, Name, Unique_Id__c
											FROM Account 
											WHERE  Id =: userList[0].Account.ParentId];	
		dealerAccountList[0].Unique_Id__c='nullewtg24662-rwffs2453-gdgs';
		Database.update(dealerAccountList[0],true);
		Boolean flag=false;
		try {
			System.runAs(userList[0]) {

				Test.startTest();
	
				// Set mock callout
				Test.setMock(HttpCalloutMock.class, new PowerBiEmbedManagerMock());
	
				// Call the method to test
				PowerBiEmbedManager.PowerBiReportData reportData = PowerBiEmbedManager.getEmbeddingDataForReport(null);
					// Verify the results
			
				System.assertEquals(EXPECTED_MOCK_REPORT, reportData.name);
				System.assertEquals(EXPECTED_MOCK_URL, reportData.embedUrl);
				System.assertEquals(EXPECTED_EMBED_TOKEN, reportData.embedToken);
				System.assertNotEquals(null, reportData.embedTokenExpires);
				System.assertEquals(null, reportData.error);

				Test.stopTest();
			}
		} catch (Exception exceptionObj) {
			flag=true;
		}
		System.assertEquals(true,flag,'Exception not ocured');

		}
		
	

	public class PowerBiEmbedManagerMock implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');

			if (req.getEndpoint().contains('/oauth2/v2.0/token')) {
				// Mock response for token endpoint
				res.setBody('{"access_token": "mock_access_token", "expires_in": "3600", "ext_expires_in": "3600", "token_type": "Bearer"}');
				res.setStatusCode(200);
			} else if (req.getEndpoint().contains('/reports/')) {
				if (req.getMethod() == 'GET') {
					// Mock response for getting report data
					res.setBody('{"id": "mock_report_id", "reportType": "Report", "name": "Mock Report", "webUrl": "https://mock.url", "embedUrl": "https://mock.embed.url", "isFromPbix": false, "isOwnedByMe": true, "datasetId": "mock_dataset_id"}');
					res.setStatusCode(200);
				} else if (req.getMethod() == 'POST') {
					// Mock response for generating embed token
					res.setBody('{"token": "mock_embed_token", "tokenId": "mock_token_id", "expiration": "2024-12-31T23:59:59Z"}');
					res.setStatusCode(200);
				}
			}
			return res;
		}
	}
	
	

}