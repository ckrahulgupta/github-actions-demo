/**
 * @author          Sk Minsar
 * @description     This class is used for making Portal input fields clickable and perform portal actions by clicking the fields
 * @created         10.06.2024
 * @lastmodified    10.06.2024
 */

const everntHandler = (function () {

	const makeClickableInput = function(inputActorName, inputFieldName, buttonActorName, buttonActionName, isClickable) {
		
		const sanitizedInputFieldName = inputFieldName.replace(/\./g, "_");
		
		const $filterInputContainer = $(
			`[data-style-actor-name="${inputActorName}"] [data-style-field-name="${sanitizedInputFieldName}"]`
		);
	
		const waitForInputField = function(callback, timeout = 10000) {
			const interval = 100;
			let elapsedTime = 0;
	
			const checkExistence = () => {
				const $filterInputField = $(
					`[data-style-actor-name="${inputActorName}"] [data-style-field-name="${sanitizedInputFieldName}"] input`
				);
				if ($filterInputField.length) {
					clearInterval(intervalId);
					callback($filterInputField);
				} else if (elapsedTime >= timeout) {
					clearInterval(intervalId);
				} else {
					elapsedTime += interval;
				}
			};
	
			const intervalId = setInterval(checkExistence, interval);
		};
	
		waitForInputField(($filterInputField) => {
			const $filterInputDiv = $filterInputField.parent();
	
			const $filterInputButton = $(
				`[data-style-actor-name="${buttonActorName}"] [data-style-action-name="${buttonActionName}"]`
			);
	
			// Clear any existing click event handler
			$filterInputDiv.off('click');
	
			if (isClickable && $filterInputDiv.length && $filterInputButton.length) {
				// Set the click event handler if isClickable is true
				$filterInputDiv.click(function() {
					$filterInputButton.click();
				});
	
				// Automatically remove event handler when element is removed
				const observer = new MutationObserver((mutationsList) => {
					for (let mutation of mutationsList) {
						if (mutation.type === 'childList') {
							mutation.removedNodes.forEach((removedNode) => {
								if (removedNode.contains($filterInputDiv[0])) {
									$filterInputDiv.off('click');
									observer.disconnect();
								}
							});
						}
					}
				});
	
				observer.observe(document.body, { childList: true, subtree: true });
	
			} else if (!isClickable) {
				// If isClickable is false, remove the click event handler
				$filterInputDiv.off('click');
			}
		});
	};

	return {
		makeClickableInput: makeClickableInput
	};
})();

(function (portalext, $) {
	portalext.makeClickableInput = everntHandler.makeClickableInput;

})((window.portalext = window.portalext || {}));