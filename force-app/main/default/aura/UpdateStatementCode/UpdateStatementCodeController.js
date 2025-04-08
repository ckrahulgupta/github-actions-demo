/**
 * @description JS for the aura component - Statement Code
 * @author      Rahul Gupta
 * @created     14-02-2023
 * @updated     24-02-2023
 */
({
    /**
     * @description showCount Returns the count of the the different statement codes for active loans under 
     *                        a particular maturity date.
     * 
     * @param {any} component To take the component instance
     * @param {any} event To take the event instance
     * @param {any} helper To take the helper instance
     */
    showCount: function (component, event, helper) {

        // constants
        const MATURITY_DATE = 'MaturityDate';
        const VALUE = 'v.value';
        const VALIDITY = 'v.validity';
        const STATEMENT_CODE_FREQUENCIES = 'v.statementCodeFrequencies';
        const SHOW_LOADER = 'v.showLoader';
        const GET_STATEMENT_CODE_COUNT = 'c.getStatementCodeCount';
        const SUCCESS = 'SUCCESS';
        const ERR_EMPTY_MATURITY_DATE = 'Please enter a maturity date.';
        const ERR_INVALID_MATURITY_DATE = 'Please enter a valid maturity date.';

        let maturityDate = component.find(MATURITY_DATE).get(VALUE);
        let maturityDateValidity = component.find(MATURITY_DATE).get(VALIDITY);

        if (maturityDate == null || maturityDate == undefined) {
            component.find(MATURITY_DATE).showHelpMessageIfInvalid();
            throw new Error(ERR_EMPTY_MATURITY_DATE);
        }

        if (!maturityDateValidity.valid) {
            component.find(MATURITY_DATE).showHelpMessageIfInvalid();
            throw new Error(ERR_INVALID_MATURITY_DATE);
        }

        component.set(SHOW_LOADER, true);

        let action = component.get(GET_STATEMENT_CODE_COUNT);

        action.setParams({
            maturityDate: maturityDate
        });

        action.setCallback(this, response => {
            let state = response.getState();

            if (state == SUCCESS) {
                let data = response.getReturnValue();

                let statementCodeFrequencyList = [];

                for (const statementCode of Object.keys(data)) {
                    let statementCodeFrequency = {
                        statementCode: statementCode,
                        frequency: data[statementCode]
                    };

                    statementCodeFrequencyList.push(statementCodeFrequency);
                }

                component.set(STATEMENT_CODE_FREQUENCIES, statementCodeFrequencyList);
                component.set(SHOW_LOADER, false);
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description downloadLoansCsv Creates a CSV of all the active loans under a particular maturity date 
     *                               and downloads it in the client.
     * 
     * @param {any} component To take the component instance.
     * @param {any} event To take the event instance
     * @param {any} helper To take the helper instance
     */
    downloadLoansCsv: function (component, event, helper) {

        // constants
        const MATURITY_DATE = 'MaturityDate';
        const VALUE = 'v.value';
        const VALIDITY = 'v.validity';
        const SHOW_LOADER = 'v.showLoader';
        const GET_LOANS_FOR_MATURITY_DATE = 'c.getLoansForMaturityDate';
        const SUCCESS = 'SUCCESS';
        const CSV_COLUMNS = 'LOAN NUMBER, NAME, STATEMENT CODE\n';
        const ERR_EMPTY_MATURITY_DATE = 'Please enter a maturity date.';
        const ERR_INVALID_MATURITY_DATE = 'Please enter a valid maturity date.';
        const BLANK = '_blank';

        let maturityDate = component.find(MATURITY_DATE).get(VALUE);
        let maturityDateValidity = component.find(MATURITY_DATE).get(VALIDITY);

        if (maturityDate == null || maturityDate == undefined) {
            component.find(MATURITY_DATE).showHelpMessageIfInvalid();
            throw new Error(ERR_EMPTY_MATURITY_DATE);
        }

        if (!maturityDateValidity.valid) {
            component.find(MATURITY_DATE).showHelpMessageIfInvalid();
            throw new Error(ERR_INVALID_MATURITY_DATE);
        }

        component.set(SHOW_LOADER, true);

        let action = component.get(GET_LOANS_FOR_MATURITY_DATE);

        action.setParams({
            maturityDate: maturityDate
        });

        action.setCallback(this, response => {
            let state = response.getState();

            if (state == SUCCESS) {
                let data = response.getReturnValue();

                let csvContent = CSV_COLUMNS;

                data.forEach(item => {
                    csvContent += item.genesis__Loan_Number__c + ', ' 
                                    + item.genesis__Account__r.Name.replaceAll(',', '') + ', ' 
                                    + item.Statement_Code__c + '\n';
                });

                let hiddenElement = document.createElement('a');  
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);  
                hiddenElement.target = BLANK;  
                
                //provide the name for the CSV file to be downloaded  
                hiddenElement.download = `Statement-Code-Report-${maturityDate}.csv`;  
                hiddenElement.click();

                component.set(SHOW_LOADER, false);
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description updateStatementCode Updates the statement codes of the active loans under a particular maturity date.
     *                                  (7 -> 1 & 8 -> 6).
     * 
     * @param {any} component To take the component instance.
     * @param {any} event To take the event instance.
     * @param {any} helper To take the helper instance.
     */
    updateStatementCode: function (component, event, helper) {
        // constants
        const MATURITY_DATE = 'MaturityDate';
        const VALUE = 'v.value';
        const VALIDITY = 'v.validity';
        const SHOW_LOADER = 'v.showLoader';
        const TOAST = 'e.force:showToast';
        const UPDATE_LOANS_FOR_MATURITY_DATE = 'c.updateLoanStatementCodeForMaturityDate';
        const CLOSE_POPUP = 'e.force:closeQuickAction';
        const SUCCESS = 'SUCCESS';
        const ERR_EMPTY_MATURITY_DATE = 'Please enter a maturity date.';
        const ERR_INVALID_MATURITY_DATE = 'Please enter a valid maturity date.';
        const TOAST_TITLE = 'The updation of the statement codes has been initiated.';
        const TOAST_MESSAGE = 'It will take some time to complete. Thank you.';

        let maturityDate = component.find(MATURITY_DATE).get(VALUE);
        let maturityDateValidity = component.find(MATURITY_DATE).get(VALIDITY);

        if (maturityDate == null || maturityDate == undefined) {
            component.find(MATURITY_DATE).showHelpMessageIfInvalid();
            throw new Error(ERR_EMPTY_MATURITY_DATE);
        }

        if (!maturityDateValidity.valid) {
            component.find(MATURITY_DATE).showHelpMessageIfInvalid();
            throw new Error(ERR_INVALID_MATURITY_DATE);
        }

        component.set(SHOW_LOADER, true);

        let action = component.get(UPDATE_LOANS_FOR_MATURITY_DATE);

        action.setParams({
            maturityDate: maturityDate
        });

        action.setCallback(this, response => {
            let state = response.getState();

            if (state == SUCCESS) {

                let toastEvent = $A.get(TOAST);
                toastEvent.setParams({
                    'title': TOAST_TITLE,
                    'message': TOAST_MESSAGE
                });

                component.set(SHOW_LOADER, false);

                toastEvent.fire();

                $A.get(CLOSE_POPUP).fire();
            }
        });

        $A.enqueueAction(action);
    }
});