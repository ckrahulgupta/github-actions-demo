/**
 * @author          Rahul Gupta
 * @description     Custom JS to indicate whether the loan limits are below threshold
 *                  on the CL Portal
 * @created         10.07.2022
 * @lastmodified    08.07.2024
 */

const changeLimitFieldColor = function(caller) {
    var $dealerLoanLimitsHtml;
    var remainingContractLoanLimitTableHeadingHtml;
    var remainingContractLoanLimitValueHtml;

    $dealerLoanLimitsHtml = $(`div[data-style-actor-name="dealerLoanLimits"]`);
    
    if ($dealerLoanLimitsHtml.length != 0) {
        remainingContractLoanLimitTableHeadingHtml = $dealerLoanLimitsHtml[0].querySelectorAll('thead th')[caller.fieldOrder];
        remainingContractLoanLimitValueHtml = $dealerLoanLimitsHtml[0].querySelector(`div[data-style-field-name=${caller.fieldName}]`);

        if (caller.value < caller.threshold) {
            // Change color to red
            if ($dealerLoanLimitsHtml.length != 0) {
                if (remainingContractLoanLimitTableHeadingHtml) {
                    remainingContractLoanLimitTableHeadingHtml.style.color = 'rgb(241 127 40)';
                }

                if (remainingContractLoanLimitValueHtml) {
                    remainingContractLoanLimitValueHtml.style.color = 'rgb(241 127 40)';
                }
            } 
        } else {
            // Change color to initial
            if ($dealerLoanLimitsHtml.length != 0) {
                if (remainingContractLoanLimitTableHeadingHtml) {
                    remainingContractLoanLimitTableHeadingHtml.style.color = 'var(--secondary-color)';
                }

                if (remainingContractLoanLimitValueHtml) {
                    remainingContractLoanLimitValueHtml.style.color = 'var(--primary-color)';
                }
            }
        }
    }
}

var indicator = (function() {
    var contractLimit = {};
    var customizedLimit = {};

    const setContractLimit = function(caller) {
        contractLimit = caller;
    }

    const setCustomizedLimit = function(caller) {
        customizedLimit = caller;
    }
    
    $('html').on('DOMNodeInserted', function() {
        // updating for contract limit field
        changeLimitFieldColor(contractLimit);
        // updating for customized limit field
        changeLimitFieldColor(customizedLimit);
        
    });

    return {
        setContractLimit: setContractLimit,
        setCustomizedLimit: setCustomizedLimit
    }
    

})();

portalext.loanLimitThresholdExceededIndicator = (threshold, value, type) => {

    $(document).ready(function() {
        var currentCaller = {};

        value = value * 100;

        if (type === 'contractLimit') {
            currentCaller = {
                threshold: threshold,
                value: value,
                fieldName: 'genesis__Business_Information__r_Remaining_Contract_Limit__c',
                fieldOrder: 1
            };
            indicator.setContractLimit(currentCaller);
        } else if (type === 'customizedLimit') {
            currentCaller = {
                threshold: threshold,
                value: value,
                fieldName: 'genesis__Business_Information__r_Remaining_Customised_Limit__c',
                fieldOrder: 4
            };
            indicator.setCustomizedLimit(currentCaller);
        }

        changeLimitFieldColor(currentCaller);
        
    });
}