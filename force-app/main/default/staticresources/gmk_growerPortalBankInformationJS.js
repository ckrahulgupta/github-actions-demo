/**
 * @author          Rahul Gupta
 * @description     Auto-populate bank information based upon routing number and
 *                  integration with CL Portal
 * @created         27.06.2022
 * @lastmodified    28.06.2022
 */

const bankInformation = (function() {
    // const API_ENDPOINT = "https://routingnumbers.herokuapp.com/api/data.json";
    const API_ENDPOINT = "https://www.routingnumbers.info/api/data.json";

	// string helper constants
	const VALUE_TXT = "value";
	const INPUT_TXT = "input";

	// will contain bank routing number input DOM element
	var $bankRoutingNumberInputField;
	// will contain bank name input DOM element
	var $bankNameInputField;
	// will contain bank phone number input DOM element
	var $bankPhoneNumberInputField;
	// will contain bank street input DOM element
	var $bankStreetInputField;
	// will contain bank city input DOM element
	var $bankCityInputField;
	// will contain bank state input DOM element
	var $bankStateInputField;
	// will contain bank postal code input DOM element
	var $bankZipInputField;

    // AJAX 'GET' request
	const get = function (endPoint, params, callBack) {
		$.ajax({
			url: endPoint,
			data: params,
			dataType: "json",
			success: callBack,
			error: (error) => error,
		});
	};

    // inject form field with native values
	const setNativeValue = function (field, value) {
		try {
			let valueSetter = Object.getOwnPropertyDescriptor(
				field,
				VALUE_TXT
			).set;

			let prototype = Object.getPrototypeOf(field);

			let prototypeValueSetter = Object.getOwnPropertyDescriptor(
				prototype,
				VALUE_TXT
			).set;

			if (valueSetter && valueSetter !== prototypeValueSetter) {
				prototypeValueSetter.call(field, value);
			} else {
				valueSetter.call(field, value);
			}

			field.dispatchEvent(
				new Event(INPUT_TXT, {
					bubbles: true,
				})
			);
		} catch (error) {
			console.error(error);
		}
	};

    const getBankInformation = function(routingNumber, fields, actorName, recordId) {
		
		// caching street input DOM element
		$bankNameInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${recordId}-"][data-style-field-name="${fields.bankName}"] input`
		);

		$bankPhoneNumberInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${recordId}-"][data-style-field-name="${fields.bankPhone}"] input`
		);

		$bankStreetInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${recordId}-"][data-style-field-name="${fields.bankStreet}"] input`
		);

		$bankCityInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${recordId}-"][data-style-field-name="${fields.bankCity}"] input`
		);

		$bankStateInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${recordId}-"][data-style-field-name="${fields.bankState}"] input`
		);

		$bankZipInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${recordId}-"][data-style-field-name="${fields.bankZip}"] input`
		);

		console.log("Inside fieldchange event: ", routingNumber);
		if (routingNumber.length == 9) {
			
			get(API_ENDPOINT, {
				"rn": routingNumber
			}, function(response) {
				// console.log(response.customer_name, fields.bankName, $bankNameInputField);
				// console.log(response.telephone, fields.bankPhone, $bankPhoneNumberInputField);
				// console.log(response.address, fields.bankStreet, $bankStreetInputField);
				// console.log(response.city, fields.bankCity, $bankCityInputField);
				// console.log(response.state, fields.bankState, $bankStateInputField);
				// console.log(response.zip, fields.bankZip, $bankZipInputField);

				setNativeValue($bankNameInputField[0], response.customer_name || '');
				setNativeValue($bankPhoneNumberInputField[0], response.telephone || '');
				setNativeValue($bankStreetInputField[0], response.address || '');
				setNativeValue($bankCityInputField[0], response.city || '');
				setNativeValue($bankStateInputField[0], response.state || '');
				setNativeValue($bankZipInputField[0], response.zip || '');
			})
		}
	}

	return {
		getBankInformation: getBankInformation,
	};
})(window);


(function (portalext, $) {
	// calling Smartystreets address suggestions
	portalext.bankInformation = bankInformation.getBankInformation;
})((window.portalext = window.portalext || {}));