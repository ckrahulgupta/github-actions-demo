import { LightningElement, api, wire } from 'lwc';
import getEmbeddingDataForReport from '@salesforce/apex/PowerBiEmbedManager.getEmbeddingDataForReport';
import powerbijs from '@salesforce/resourceUrl/powerbijs';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class PowerBiReport extends LightningElement {

	// @api WorkspaceId ='';
	// @api ReportId ='';

	// @api CoopTypeTable = '';
	// @api CoopTypeField = '';
	// @api CoopTypeValue = '';
	// @api DealerTable = '';
	// @api DealerField = '';
	// @api DealerValues = '';

	@api reportName = '';

	// CoopTypeTable = "$CoopTypeTable";  
	// CoopTypeField = "$CoopTypeField";
	// CoopTypeValue = "$CoopTypeValue";

	// DealerTable = "$DealerTable";
	// DealerField = "$DealerField";
	// DealerValues = "$DealerValues";


	// @wire(getEmbeddingDataForReport, {
	// 	WorkspaceId: "$WorkspaceId",
	// 	ReportId: "$ReportId"
	// }) report;

	@wire(getEmbeddingDataForReport, {
		reportName: "$reportName"
	}) report;

	renderedCallback() {
		console.log('renderedCallback exectuting');

		Promise.all([loadScript(this, powerbijs)]).then(() => {

			console.log('renderedCallback 2');

			if (this.report.data) {

				if (this.report.data.embedUrl && this.report.data.embedToken) {
					var reportContainer = this.template.querySelector('[data-id="embed-container"');

					var reportId = this.report.data.reportId;
					var embedUrl = this.report.data.embedUrl;
					var token = this.report.data.embedToken;


					var models = window['powerbi-client'].models;
					

					
					const uniqueIdBasicFilter = {
						$schema: "https://powerbi.com/product/schema#basic",
						target: {
							table: this.report.data.uniqueIdTable,
							column: this.report.data.uniqueIdField
						},
						operator: "Eq",
						values: JSON.parse('["' + this.report.data.uniqueIdValues + '"]'),
						filterType: models.FilterType.BasicFilter,
						requireSingleSelection: true
					};
                    var config = {
						type: 'report',
						id: reportId,
						embedUrl: embedUrl,
						accessToken: token,
						tokenType: 1,
						filters: [uniqueIdBasicFilter],
						settings: {
							
							panes: {
								filters: { expanded: false, visible: false },
								bookmarks: { visible: false},
								pageNavigation: { visible: false }
							},
							bars: {
								actionBar: {
									visible: true
								}
							},
							layoutType: models.LayoutType.Custom,
							customLayout:{
								displayOption:models.DisplayOption.FitToWidth,
								pageSize:{
									type:models.PageSizeType.Widescreen,
									
								}
							}
						}
					};
					var report = powerbi.embed(reportContainer, config);
				}
				else {
					console.log('no embedUrl or embedToken');
				}

			}
			else {
				console.log('no report.data yet');
			}
		});
	}
}