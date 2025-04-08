/**
 * @description       : Helper functions used frequently in Grower Portal
 * @author            : Rahul Gupta
 * @group             : 
 * @created           : 12-23-2021
 * @last modified on  : 15-02-2025
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

    portalext.changeDateFormat = (value) => {
		const year = value.slice(0,4);
		const month = value.slice(5,7);
		const day = value.slice(8,10);

		return month + '/' + day + '/' + year
	}

    portalext.downloadStatement = (statementBase64) => {
        var aHtml = window.top.document.createElement("a"); // Create <a>
        aHtml.href = "data:application/pdf;base64," + statementBase64; // PDF Base64 Goes here
        aHtml.download = "statement.pdf"; // File name Here
        aHtml.click();
    }

    portalext.downloadDocument = (docBase64DataUrl, fileName, ext) => {
        var aHtml = window.top.document.createElement("a"); // Create <a>
        aHtml.href = docBase64DataUrl; // PDF Base64 Goes here
        aHtml.download = `${fileName}.${ext}`; // File name Here
        aHtml.click();
    }

    portalext.openUrl = (url, target) => window.open(url, target);

    portalext.formatSSN = (ssn, flag) => {
        if (flag) 
            return ssn.substring(0, 3) + '-' + ssn.substring(3, 5) + '-' + ssn.substring(5, 9);
        else 
            return ssn;
    }


    Date.prototype.getFormattedDate = function () {
        return this.getFullYear() + '-' 
                        + ('0' + (this.getMonth() + 1)).slice(-2) + '-' 
                        + ('0' + this.getDate()).slice(-2);
    }

    Date.prototype.addDays = function (days) {

        this.setDate(this.getDate() + days);

        return this;
    }

    portalext.getCurrentDate = () => {
        let date = new Date();
        return date.getFormattedDate();
    }

    portalext.getCurrentDateWithOffset = (offset) => {
        let date = new Date();

        date.addDays(offset);

        return date.getFormattedDate();
    }

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
				// fed tax id field on initiate application form
                'div[data-style-actor-name="growerAddNewApplicant"] div[data-style-field-name="Fed_Tax_ID"] input',

                // confirm fed tax id field on initiate application form
                'div[data-style-actor-name="growerAddNewApplicant"] div[data-style-field-name="Confirm_Fed_Tax_ID"] input',

                // ssn field on initiate application form
                'div[data-style-actor-name="growerAddNewApplicant"] div[data-style-field-name="SSN"] input',

                // confirm ssn field on initiate application form
                'div[data-style-actor-name="growerAddNewApplicant"] div[data-style-field-name="Confirm_SSN"] input',

                // ssn field on landus registration form 
                'div[data-style-actor-name="growerSignUpForm"] div[data-style-field-name="SSN"] input',

                // confirm ssn field on landus registration form
                'div[data-style-actor-name="growerSignUpForm"] div[data-style-field-name="Confirm_SSN"] input',

                // ssn field on grower portal register form
                'div[data-style-actor-name="growerRegistrationForm"] div[data-style-field-name="SSN"] input',

                // confirm ssn field on portal register form
                'div[data-style-actor-name="growerRegistrationForm"] div[data-style-field-name="Confirm_SSN"] input',

                // fed tax id field on business information form
                'div[data-style-actor-name="growerPrimaryApplicantBusinessInformation"] div[data-style-field-name="clcommon__Account__r_genesis__Business_Information__r_genesis__Tax_Identification_Number__c"] input',

                // confirm fed tax id field on business information form
                'div[data-style-actor-name="growerPrimaryApplicantBusinessInformation"] div[data-style-field-name="clcommon__Account__r_genesis__Business_Information__r_Confirm_Tax_Identification_Number__c"] input',

                // ssn field on individual information form
                'div[data-style-actor-name="growerPrimaryApplicantIndividualInformation"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input',
                
                // confirm ssn field on individual information form
                'div[data-style-actor-name="growerPrimaryApplicantIndividualInformation"] div[data-style-field-name="clcommon__Contact__r_Confirm_SSN__c"] input',
                
                // ssn field on co-applicant information form
                'div[data-style-actor-name="growerCoApplicantInformation"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input',
                
                // confirm ssn field on co-applicant information form
                'div[data-style-actor-name="growerCoApplicantInformation"] div[data-style-field-name="clcommon__Contact__r_Confirm_SSN__c"] input',
                
                // ssn field on spouse information list
                'div[data-style-actor-name="growerSpouseInformationList"] div[data-style-field-name="clcommon__Contact__r_genesis__SSN__c"] input',

                // ssn field on profile information
                'div[data-style-actor-name="growerWritePersonalInformation"] div[data-style-field-name="genesis__SSN__c"] input'
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
        return event.returnValue = 'Please make sure to select Save before closing this window. Closing the window without doing a Save & Exit will result in all of the information being deleted. Would you like to proceed with closing the window ?';
    }

    window.addEventListener('beforeunload', onBeforeUnload, {capture: true});

})(window.portalext = window.portalext || {});
