/**
 * @description       : Helper functions used frequently in Dealer Portal
 * @author            : Rahul Gupta
 * @group             : 
 * @created           : 12-23-2021
 * @last modified on  : 17-02-2025
 * @last modified by  : Soumik Pattanayak
**/

((portalext) => {

	portalext.getUnescapedSpecialCharString = (value) => {

		if(value === undefined){
			return "";
		}else{
			return value.replace(/&quot;/g, '"')
						.replace(/&#39;/g, "'")
						.replace(/&gt;/g, ">")
						.replace(/&lt;/g, "<")
						.replace(/&amp;/g, "&");
		}
	}

	portalext.getIntegerValue = (stringValue) => {

		if(stringValue === undefined){
			return 0;
		}else{
			return parseInt(stringValue);
		}
	}

	portalext.validateExcessAmountAllowance = (paymentOption, paymentAmount, totalPayOffAmount) => {

		if(paymentOption === "recordMobileDeposit"){
			return true;
		}else{
			if(parseInt(paymentAmount) <= parseInt(totalPayOffAmount) && parseInt(paymentAmount) >= 0){
				return true;
			}else{
				return false;
			}
		}
	}

	portalext.changeDateFormat = (value) => {
		const year = value.slice(0,4);
		const month = value.slice(5,7);
		const day = value.slice(8,10);

		return month + '/' + day + '/' + year
	}

	portalext.confirmAge = (dateValue, minAge) => {
		var today = new Date();
		var birthDate = new Date(dateValue);
		var age = today.getFullYear() - birthDate.getFullYear();
		var m = today.getMonth() - birthDate.getMonth();
		if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
			age = age - 1;
		}

		return age >= minAge;
	};

	portalext.downloadStatement = (statementBase64) => {
		var aHtml = window.top.document.createElement("a"); // Create <a>
		aHtml.href = "data:application/pdf;base64," + statementBase64; // PDF Base64 Goes here
		aHtml.download = "statement.pdf"; // File name Here
		aHtml.click();
	};

	portalext.downloadDocument = (docBase64DataUrl, fileName, ext) => {
		var aHtml = window.top.document.createElement("a"); // Create <a>
		aHtml.href = docBase64DataUrl; // PDF Base64 Goes here
		aHtml.download = `${fileName}.${ext}`; // File name Here
		aHtml.click();
	};

	portalext.openUrl = (url, target) => window.open(url, target);

	portalext.formatSSN = (ssn, flag) => {
		if (flag)
			return (
				ssn.substring(0, 3) +
				"-" +
				ssn.substring(3, 5) +
				"-" +
				ssn.substring(5, 9)
			);
		else return ssn;
	};

	Date.prototype.getFormattedDate = function () {
		return (
			this.getFullYear() +
			"-" +
			("0" + (this.getMonth() + 1)).slice(-2) +
			"-" +
			("0" + this.getDate()).slice(-2)
		);
	};

	Date.prototype.addDays = function (days) {
		this.setDate(this.getDate() + days);

		return this;
	};

	portalext.validateMaturityDate = (maturityDateString) => {
		try {
			let nextMonthDate = new Date();

			let maturityDate = new Date(maturityDateString);

			nextMonthDate.setMonth(nextMonthDate.getMonth() + 1);

			let nextMonth = nextMonthDate.getMonth();

			let nextMonthYear = nextMonthDate.getFullYear();

			let maturityMonth = maturityDate.getMonth();

			let maturityYear = maturityDate.getFullYear();

			if (
				nextMonth == maturityMonth &&
				nextMonthYear == maturityYear &&
				new Date().getDay() >= 26
			) {
				return true;
			}

			if (nextMonth > maturityMonth && nextMonthYear >= maturityYear) {
				return true
			}

			return false;
		} catch (e) {
			console.log(e);
		}
	};

	portalext.splitDraftNumber = (draftNumber) => {
		return draftNumber.slice(6);
	}

	portalext.getCurrentDate = () => {
		let date = new Date();
		return date.getFormattedDate();
	};

	portalext.getCurrentDateWithOffset = (offset) => {
		let date = new Date();

		date.addDays(offset);

		return date.getFormattedDate();
	};

	portalext.addYearsToCurrentCropYear = (currentCropYear, yearsToAdd) => {
		let numberInt = parseInt(currentCropYear, 10);
		return (numberInt + yearsToAdd).toString();
	};

	//////////////////////////////////////
	
	$(document).ready(function () {
		// Create a MutationObserver to watch for DOM changes
		const observer = new MutationObserver(function (mutations) {
			mutations.forEach(function (mutation) {
				// Ensure the new node is added
				if (mutation.type === 'childList' && mutation.addedNodes.length) {
					disableCutCopyPaste();
				}
			});
		});
	
		// Configuration for the observer
		const config = { childList: true, subtree: true };
	
		// Start observing the document body for DOM changes
		observer.observe(document.body, config);
	
		// Function to disable cut, copy, paste for the relevant input fields
		function disableCutCopyPaste() {
			const inputSelectors = [
				// Fed Tax ID and Confirm Fed Tax ID fields on initiate application form
				'div[data-style-actor-name="dealerAddNewApplicant"] div[data-style-field-name="Fed_Tax_ID"] input',
				'div[data-style-actor-name="dealerAddNewApplicant"] div[data-style-field-name="Confirm_Fed_Tax_ID"] input',
	
				// SSN and Confirm SSN fields on initiate application form
				'div[data-style-actor-name="dealerAddNewApplicant"] div[data-style-field-name="SSN"] input',
				'div[data-style-actor-name="dealerAddNewApplicant"] div[data-style-field-name="Confirm_SSN"] input',
	
				// Fed Tax ID and Confirm Fed Tax ID fields on business information form
				'div[data-style-actor-name="dealerPrimaryApplicantBusinessInformation"] div[data-style-field-name="clcommon__Account__r_genesis__Business_Information__r_genesis__Tax_Identification_Number__c"] input',
				'div[data-style-actor-name="dealerPrimaryApplicantBusinessInformation"] div[data-style-field-name="clcommon__Account__r_genesis__Business_Information__r_Confirm_Tax_Identification_Number__c"] input',
	
				// SSN and Confirm SSN fields on individual information form
				'div[data-style-actor-name="dealerPrimaryApplicantIndividualInformation"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input',
				'div[data-style-actor-name="dealerPrimaryApplicantIndividualInformation"] div[data-style-field-name="clcommon__Contact__r_Confirm_SSN__c"] input',
	
				// SSN and Confirm SSN fields on co-applicant information form
				'div[data-style-actor-name="dealerCoApplicantInformation"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input',
				'div[data-style-actor-name="dealerCoApplicantInformation"] div[data-style-field-name="clcommon__Contact__r_Confirm_SSN__c"] input',

				// SSN and Confirm SSN fields on add new co-applicant form
				'div[data-style-actor-name="dealerAddNewCoApplicantContainer"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input',
				'div[data-style-actor-name="dealerAddNewCoApplicantContainer"] div[data-style-field-name="clcommon__Contact__r_Confirm_SSN__c"] input',
	
				// SSN field on spouse information list
				'div[data-style-actor-name="dealerSpouseInformationList"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input'
			];
	
			// Disable cut, copy, paste for each of the input fields
			inputSelectors.forEach(function (selector) {
				var $input = $(selector);
				$input.off("cut copy paste");
				$input.on("cut copy paste", function (event) {
					event.preventDefault();
				});
			});
		}
	
		// Initial call to disable cut, copy, paste for existing elements
		disableCutCopyPaste();
	});

	//////////////////////////////////////

	window.addEventListener("DOMNodeInserted", (event) => {
		var $inputs = $(
			'[data-style-actor-name="dealerApplicationTabs"] input'
		);

		var $dropdowns = $(
			'[data-style-actor-name="dealerApplicationTabs"] .MuiSelect-root'
		);

		if ($inputs != undefined && $inputs.length !== 0) {
			$inputs.each((idx, input) => {
				if (input.oninput == null || input.oninput == undefined) {
					input.oninput = function () {
						applicationInformationChanged = true;
					};
				}
			});
		}

		if ($dropdowns != undefined && $dropdowns.length !== 0) {
			$dropdowns.each((idx, select) => {
				if (select.click == null || select.click == undefined) {
					select.click = function () {
						applicationInformationChanged = true;
					};
				}
			});
		}
	});

	/**
	 * @description Callback function for the 'beforeunload' event.
	 *
	 * @notes Showing custom message before unloading is depricated and
	 *        is not supported by modern browsers.
	 *
	 *        Messages for popular browsers -
	 *
	 *        1. Chrome: 'Do you want to leave this site? Changes you made may not be saved'.
	 *        2. Firefox: 'This page is asking you to confirm that you want to
	 *                     leave - data you have entered may not be saved.'
	 *
	 * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
	 */
	function onBeforeUnload(event) {
		event.preventDefault();

		// fallback text to show incase the browser supports custom message
		// on the beforeunload event
		return (event.returnValue =
			"Please make sure to select Save before closing this window. Closing the window without doing a Save & Exit will result in all of the information being deleted. Would you like to proceed with closing the window ?");
	}

	window.addEventListener("beforeunload", onBeforeUnload, { capture: true });
})((window.portalext = window.portalext || {}));