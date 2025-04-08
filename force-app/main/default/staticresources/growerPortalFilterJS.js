/**
 * @author          Tuhin Bhunia
 * @description     Used to dynamically inject filter options on the portal
 * @created         21.02.2024
 * @lastmodified    21.02.2024
 */

const growerPortalFilters = (function () {
	// string helper constants
	const VALUE_TXT = 'value';
	const INPUT_TXT = 'input';

	// months array
	const MONTHS = [
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December'
	];

	// will contain filter input container DOM element
	var $filterInputContainer;
	// will contain filter options list DOM element
	var $menu;

	// will contain filter input DOM element
	var $filterInputField;
	//will contain filter input parent Div DOM 	element
	var $filterInputDiv;

	const getCurrentYear = () => new Date().getFullYear();

	const getCurrentCropYear = () => {
		var today = new Date();

		if (today.getMonth() >= 6) {
			// next year
			return today.getFullYear() + 1;
		} else {
			// current year
			return today.getFullYear();
		}

	}

	const getCurrentMonthAndYear = () => {
		var today = new Date();
		today.setMonth(today.getMonth() - 1);
		return MONTHS[today.getMonth()] + ' ' + today.getFullYear();
	}


	// construct DOM for filter options
	const buildFilter = function (filterOptions) {
		if (filterOptions) {
			buildFilterOptions(filterOptions);
		}
	};

	// inject menu
	const injectSuggestionMenu = function () {
		if ($menu) {
			$menu.remove();
		}

		$filterInputContainer.append(
			'<ul class="us-autocomplete-pro-menu"></ul>'
		);
		$menu = $filterInputContainer.find('.us-autocomplete-pro-menu');
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
	const buildFilterOptions = function (filterOptions) {
		// injecting the filter options list element
		injectSuggestionMenu();

		filterOptions.map((option) => {
			$menu.append(
				`<li>
                    <div data-address=\"${option}\">
                        ${option}</b>
                    </div>
                </li>`
			);
		});

		// selecting a filter option and further operations
		$menu.menu({
			select: (event, ui) => {
				let filterOption =
					ui.item[0].childNodes[1].dataset.address.split(';');

				// setting the filter value
				setNativeValue($filterInputField[0], filterOption[0]);
			},
		});

		// scrolling through filter options
		$filterInputField.keyup((event) => {

			if (event.key === 'ArrowDown') {
				$menu.focus();
				$menu.menu('focus', null, $menu.menu().find('.ui-menu-item'));
			}
		});

		$menu.menu('refresh');
	};

	const generateMonthYearOption = function () {
		let filterOptions = [];

		var today = new Date();

		today.setDate(0);

		for (let i = 0, month = today.getMonth(), year = today.getFullYear(); i < 23; i++) {

			filterOptions.push(MONTHS[month] + ' ' + year);
			month--;
		
			if (month < 0) {
				month = 11;
				year--;
			}
		}

		return filterOptions;
	}

	const generateYearOption = function () {
		let filterOptions = [];

		var date = new Date();

		for (i = date.getFullYear() - 1; i >= date.getFullYear() - 2; i--) {
			filterOptions.push(i);
		}

		return filterOptions;
	}

	const generateCropYearOption = function () {
		let filterOptions = [];

		var currentCropYear = getCurrentCropYear();

		for (i = currentCropYear; i >= currentCropYear - 5; i--) {
			filterOptions.push(i);
		}

		return filterOptions;
	}

	const generateCalendarYearOption = function (toDateString) {

		let toDate = new Date(toDateString);

		let filterOptions = [];
		
		var currentCropYear = getCurrentCropYear();

		for (i = currentCropYear; i >= toDate.getFullYear(); i--) { // from posted to nls year to current crop year
			filterOptions.push(i);
		}
		return filterOptions;
	}

	// get filter options
	const getReportFilters = function (field, actorName, filterType) {

		// caching filter input field container DOM element
		$filterInputContainer = $(
			`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"]`
		);

		// caching filter input DOM element
		$filterInputField = $(
			`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"] input`
		);
		$filterInputDiv = $filterInputField.parent();
		$filterInputField[0].setAttribute('readonly', true);

		// caching filter options list DOM element
		$menu =
			$filterInputContainer.find('.us-autocomplete-pro-menu') ||
			undefined;

		let filterOptions = [];

		if (filterType == 'Month - Year') {
			filterOptions = generateMonthYearOption();

			if ($filterInputField[0].value == '') {
				setNativeValue($filterInputField[0], getCurrentMonthAndYear());
			}

		} else if (filterType == 'Year') {
			filterOptions = generateYearOption();

			if ($filterInputField[0].value == '') {
				setNativeValue($filterInputField[0], getCurrentYear() - 1);
			}

		} else if (filterType == 'Crop Year') {
			filterOptions = generateCropYearOption();

			if ($filterInputField[0].value == '') {
				setNativeValue($filterInputField[0], getCurrentCropYear());
			}
		}

		$filterInputDiv.click(function () {
			// caching filter input field container DOM element
			$filterInputContainer = $(
				`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"]`
			);

			// caching filter input DOM element
			$filterInputField = $(
				`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"] input`
			);

			$filterInputField[0].setAttribute('readonly', true);

			// caching filter options list DOM element
			$menu =
				$filterInputContainer.find('.us-autocomplete-pro-menu') ||
				undefined;

			buildFilter(filterOptions);
		});

		// Remove filter options container when clicked outside
		window.addEventListener('click', (event) => {
			if ($menu && event.target != $menu[0] && $filterInputDiv && $(event.target).closest($filterInputDiv).length === 0) {
				$menu.remove();
			}
		});
	};

	const actorListToObject = function(targetActorName,targetFieldName,optionValue) {
		try {
			const loanDescriptions = [];
			loanDescriptions.push(optionValue);
			const table = $(`.actor-wrapper[data-style-actor-name="${targetActorName}"] table`);
			if (table.length === 0) {
			  return loanDescriptions; 
			}
		  
			table.find('tbody tr').each(function() {
				
				const descriptionCell = $(this).find(`div[data-style-field-name="${targetFieldName}"]`);
				const description = descriptionCell.text().trim();
				loanDescriptions.push(description);
			  });
		  	return loanDescriptions;
		} catch (error) {
		  console.error("Error = ", error);
		  return []; 
		}
	  };

	const addOptionInDropdown = function (inputField, inputActorName, optionValue, targetActorName, targetFieldName) {
     
		// caching filter input field container DOM element
		$filterInputContainer = $(
			`[data-style-actor-name="${inputActorName}"] [data-style-field-name="${inputField}"]`
		);

		// caching filter input DOM element
		$filterInputField = $(
			`[data-style-actor-name="${inputActorName}"] [data-style-field-name="${inputField}"] input`
		);
		$filterInputDiv = $filterInputField.parent();
		$filterInputField[0].setAttribute('readonly', true);

		// caching filter options list DOM element
		$menu =
			$filterInputContainer.find('.us-autocomplete-pro-menu') ||
			undefined;
		let filterOptions = [];
		
		filterOptions = actorListToObject(targetActorName,targetFieldName,optionValue);
		if(!filterOptions.includes($filterInputField[0].value)){
			setNativeValue($filterInputField[0], filterOptions[0]);
		}

		

		$filterInputDiv.click(function () {
			// caching filter input field container DOM element
			$filterInputContainer = $(
				`[data-style-actor-name="${inputActorName}"] [data-style-field-name="${inputField}"]`
			);

			// caching filter input DOM element
			$filterInputField = $(
				`[data-style-actor-name="${inputActorName}"] [data-style-field-name="${inputField}"] input`
			);

			$filterInputField[0].setAttribute('readonly', true);

			// caching filter options list DOM element
			$menu =
				$filterInputContainer.find('.us-autocomplete-pro-menu') ||
				undefined;

			buildFilter(filterOptions);
		});

		// Remove filter options container when clicked outside
		window.addEventListener('click', (event) => {
			if ($menu && event.target != $menu[0] && $filterInputDiv && $(event.target).closest($filterInputDiv).length === 0) {
				$menu.remove();
			}
		});

    };

	const getCalendarYearFilters = function (field, actorName, filterType, toDate) {

		// caching filter input field container DOM element
		$filterInputContainer = $(
			`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"]`
		);

		// caching filter input DOM element
		$filterInputField = $(
			`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"] input`
		);
		$filterInputDiv = $filterInputField.parent();
		$filterInputField[0].setAttribute('readonly', true);

		// caching filter options list DOM element
		$menu =
			$filterInputContainer.find('.us-autocomplete-pro-menu') ||
			undefined;

		let filterOptions = [];

		if (filterType == 'Calendar Year') {
			filterOptions = generateCalendarYearOption(toDate);

			if ($filterInputField[0].value == '') {
				setNativeValue($filterInputField[0], getCurrentCropYear());
			}
		}

		$filterInputDiv.click(function () {
			// caching filter input field container DOM element
			$filterInputContainer = $(
				`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"]`
			);

			// caching filter input DOM element
			$filterInputField = $(
				`[data-style-actor-name="${actorName}"] [data-style-field-name="${field}"] input`
			);

			$filterInputField[0].setAttribute('readonly', true);

			// caching filter options list DOM element
			$menu =
				$filterInputContainer.find('.us-autocomplete-pro-menu') ||
				undefined;

			buildFilter(filterOptions);
		});

		// Remove filter options container when clicked outside
		window.addEventListener('click', (event) => {
			if ($menu && event.target != $menu[0] && $filterInputDiv && $(event.target).closest($filterInputDiv).length === 0) {
				$menu.remove();
			}
		});
	};

	return {
		getReportFilters: getReportFilters,
		getCurrentMonthAndYear: getCurrentMonthAndYear,
		getCurrentYear: getCurrentYear,
		getCalendarYearFilters: getCalendarYearFilters,
		getCurrentCropYear: getCurrentCropYear,
		addOptionInDropdown: addOptionInDropdown
	};
})();

(function (portalext, $) {

	portalext.getReportFilters = growerPortalFilters.getReportFilters;
	portalext.getCurrentMonthAndYear = growerPortalFilters.getCurrentMonthAndYear;
	portalext.getCurrentYear = growerPortalFilters.getCurrentYear;
	portalext.getCalendarYearFilters = growerPortalFilters.getCalendarYearFilters;
	portalext.getCurrentCropYear = growerPortalFilters.getCurrentCropYear;
	portalext.addOptionInDropdown = growerPortalFilters.addOptionInDropdown;

})((window.portalext = window.portalext || {}));
