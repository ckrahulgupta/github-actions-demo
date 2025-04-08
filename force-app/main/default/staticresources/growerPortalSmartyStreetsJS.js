/**
 * @author          Rahul Gupta
 * @description     Smarty Streets address autocomplete and verification API
 *                  integration with CL Portal
 * @created         23.12.2021
 * @lastmodified    29.09.2022
 * @see             https://www.smartystreets.com/products/apis/us-street-api
 *                  https://www.smartystreets.com/products/apis/us-autocomplete-pro-api
 */

 const smartystreets = (function () {
	// API address autocomplete endpoint
	const AUTO_COMPL_ENDPOINT =
		"https://us-autocomplete-pro.api.smartystreets.com/lookup?";
	// API single address data endpoint
	const SINGLE_ADDR_ENDPOINT =
		"https://us-street.api.smartystreets.com/street-address?";
	// API auth key
	const _KEY = "114245061401337303";			// CFA provided key
	// const _KEY = "114302587693061408"; 		// my own generated key

	// string helper constants
	const VALUE_TXT = "value";
	const INPUT_TXT = "input";
	// API successive call delay in seconds
	const DELAY = 1;

	// will contain input container DOM element
	var $searchInputContainer;
	// will contain suggestions list DOM element
	var $menu;

	// will contain street input DOM element
	var $streetInputField;
	// will contain city input DOM element
	var $cityInputField;
	// will contain state input DOM element
	var $stateInputField;
	// will contain postal code input DOM element
	var $zipInputField;
	// will contain the county input DOM element
	var $countyInputField;

	// AJAX 'GET' request
	const get = function (endPoint, params, callBack) {
		$.ajax({
			url: endPoint,
			data: params,
			dataType: "jsonp",
			success: callBack,
			error: (error) => error,
		});
	};

	// construct DOM for address suggestions
	const buildSuggestions = function (suggestions) {
		if (suggestions) {
			buildMenu(suggestions);
		} else {
			noSuggestions();
		}
	};

	// calling SmartyStreets autocomplete address suggestions API
	const callAddressSuggestionApi = function (
		search,
		selected = "",
		callBack = undefined
	) {
		// request body
		let body = {
			key: _KEY,
			search: search || "",
			selected: selected,
		};

		// calling 'GET' request
		get(AUTO_COMPL_ENDPOINT, body, (response) => {
			if (callBack) {
				callBack(response.suggestions);
			}
		});
	};

	// get single address data
	const callSingleAddressDataApi = function (address) {
		// request body
		let body = {
			key: _KEY,
			street: address[0],
			city: address[1],
			state: address[2],
			zipcode: address[3],
		};

		// calling 'GET' request
		get(SINGLE_ADDR_ENDPOINT, body, (response) => {
			setNativeValue($zipInputField[0], response[0].components.zipcode);
			setNativeValue($countyInputField[0], response[0].metadata.county_name);
		});
	};

	// get address suggestions
	const getAddressSuggestions = function (
		search,
		fields,
		actorName,
		uniqueComponentStructureId
	) {
		// caching input field container DOM element
		$searchInputContainer = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${uniqueComponentStructureId}-"][data-style-field-name="${fields.street}"]`
		);

		// caching street input DOM element
		$streetInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${uniqueComponentStructureId}-"][data-style-field-name="${fields.street}"] input`
		);
		// caching city input DOM element
		$cityInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${uniqueComponentStructureId}-"][data-style-field-name="${fields.city}"] input`
		);
		// caching state input DOM element
		$stateInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${uniqueComponentStructureId}-"][data-style-field-name="${fields.state}"] input`
		);
		// caching postal code input DOM element
		$zipInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${uniqueComponentStructureId}-"][data-style-field-name="${fields.zip}"] input`
		);

		// caching postal code input DOM element
		$countyInputField = $(
			`[data-style-actor-name="${actorName}"] [id^="fieldwrapper-${uniqueComponentStructureId}-"][data-style-field-name="${fields.county}"] input`
		);

		// caching suggestions list DOM element
		$menu =
			$searchInputContainer.find(".us-autocomplete-pro-menu") ||
			undefined;

		// get address suggestions and render suggestions
		window.setTimeout(() => {
			callAddressSuggestionApi(search, "", buildSuggestions);
		}, DELAY);
	};

	// inject menu
	const injectSuggestionMenu = function () {
		// if the suggestions unordered list DOM already exists, then
		// remove it and create a fresh DOM every time
		if ($menu) {
			$menu.remove();
		}
		$searchInputContainer.append(
			"<ul class=\"us-autocomplete-pro-menu\"></ul>"
		);
		$menu = $searchInputContainer.find(".us-autocomplete-pro-menu");
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

	// build menu
	const buildMenu = function (suggestions) {
		// injecting the suggestions list element
		injectSuggestionMenu();

		// constructing the individual address suggestion row
		suggestions.map((suggestion) => {
			var caret =
				suggestion.entries > 1
					? "<span class=\"ui-menu-icon ui-icon ui-icon-caret-1-e\"></span>"
					: "";
			$menu.append(
				`<li>
                    <div data-address=\"${suggestion.street_line}${
					suggestion.secondary ? ` ${suggestion.secondary}` : " "
				};${suggestion.city};${suggestion.state};${
					suggestion.zipcode
				}\">
                        ${caret}${buildAddress(suggestion)}</b>
                    </div>
                </li>`
			);
		});

		// selecting an address and further operations
		$menu.menu({
			select: (event, ui) => {
				let text = ui.item[0].innerText;
				let address =
					ui.item[0].childNodes[1].dataset.address.split(";");
				let searchForMoreEntriesText = new RegExp(
					/(?:\ more\ entries\))/
				);

				// setting the street value
				setNativeValue($streetInputField[0], address[0]);
				// setting the city value
				setNativeValue($cityInputField[0], address[1]);
				// setting the state value
				setNativeValue($stateInputField[0], address[2]);
				// setting the zipcode value
				setNativeValue($zipInputField[0], address[3]);

				window.setTimeout(() => {
					callSingleAddressDataApi(address);
				}, DELAY);

				// if more similar addresses exists
				if (text.search(searchForMoreEntriesText) == "-1") {
					$menu.hide();
				} else {
					setNativeValue($streetInputField[0], address[0] + " ");
					let selected = text.replace(" more entries", "");
					selected = selected.replace(",", "");

					// get more suggestions for selected address and
					// render suggestions
					window.setTimeout(() => {
						callAddressSuggestionApi(
							address[0],
							selected,
							buildSuggestions
						);
					}, DELAY);
				}
			},
		});

		// scrolling through suggestions
		if ($streetInputField.keyup == undefined) {
			$streetInputField.keyup((event) => {
				if ($streetInputField.val() === "") {
					clearAddressData();
				}
	
				if (event.key === "ArrowDown") {
					$menu.focus();
					$menu.menu("focus", null, $menu.menu().find(".ui-menu-item"));
				} else {
					var textInput = $streetInputField.val();
					if (textInput) {
						$menu.show();
						callAddressSuggestionApi(textInput, "", buildSuggestions);
					} else {
						$menu.hide();
					}
				}
			});
		} 
		

		$menu.menu("refresh");
	};

	// build address
	const buildAddress = function (suggestion) {
		let whiteSpace = "";

		if (suggestion.secondary || suggestion.entries > 1) {
			if (suggestion.entries > 1) {
				suggestion.secondary +=
					" (" + suggestion.entries + " more entries)";
			}
			whiteSpace = " ";
		}
		let address = `${
			suggestion.street_line + whiteSpace + suggestion.secondary
		} ${suggestion.city}, ${suggestion.state} ${suggestion.zipcode}`;

		let inputAddress = $streetInputField.val();

		for (let i = 0; i < address.length; i++) {
			var theLettersMatch =
				typeof inputAddress[i] == "undefined" ||
				address[i].toLowerCase() !== inputAddress[i].toLowerCase();

			if (theLettersMatch) {
				address = [address.slice(0, i), "<b>", address.slice(i)].join(
					""
				);
				break;
			}
		}
		return address;
	};

	// clear address data
	const clearAddressData = function () {
		// resetting street value to ""
		setNativeValue($streetInputField[0], "");
		// resetting city value to ""
		setNativeValue($cityInputField[0], "");
		// resetting state value to ""
		setNativeValue($stateInputField[0], "");
		// resetting zipcode value to ""
		setNativeValue($zipInputField[0], "");
	};

	// No suggestions
	function noSuggestions() {
		$menu.empty();
		$menu.append(
			'<li class="ui-state-disabled"><div>No Suggestions Found</div></li>'
		);
		$menu.menu("refresh");
	}

	// Remove suggestion container when clicked outside
	window.addEventListener("click", (event) => {
		if ($menu && event.target != $menu) {
			$menu.remove();
		}
	});

	return {
		getAddressSuggestions: getAddressSuggestions,
	};
})();

(function (portalext, $) {
	// calling Smartystreets address suggestions
	portalext.addressSuggestions = smartystreets.getAddressSuggestions;
})((window.portalext = window.portalext || {}));
