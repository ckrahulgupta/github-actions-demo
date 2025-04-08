/**
 * @author          Rahul Gupta
 * @description     Used to dynamically inject payment spread on the portal
 * @created         11.04.2023
 * @lastmodified    07.07.2023
 * @lastmodifiedby  Tuhin Bhunia
 */
const payment = (function () {
    const VALUE_TXT = 'value';
    const INPUT_TXT = 'input';
    const INTEREST_RATE_TXT = 'interestRate';
    const PRINCIPAL_TXT = 'principal';
    const INTEREST_TXT = 'interest';
    const FEES_TXT = 'fees';
    const HTML_TXT = 'html';
    const NUMBER_REGEX = /[^0-9\.]/g;

    /**
     * Injects value in the portal fields.
     * 
     * @param {any} field input field element in which the the value will be set
     * @param {any} value value to be set in the input field
     */
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

    /**
     * Sorts the payment object in descending order of their interest rates.
     * 
     * @param {any} paymentObject payment object to be sorted
     * @returns the sorted object
     */
    const sortObject = function (paymentObject) {
        let sortedObject = {};

        try {
            let sortedKeys = Object.keys(paymentObject)
                .sort((a, b) => paymentObject[b][INTEREST_RATE_TXT]
                    - paymentObject[a][INTEREST_RATE_TXT]);

            sortedKeys.forEach(key => {
                sortedObject[key] = paymentObject[key];
            });
        } catch (error) {
            console.error(error);
        }

        return sortedObject;
    }

    /**
     * Converts the table into a payment amounts JS object.
     * 
     * @param {any} $content table element for the payment amounts table
     * @returns the payment amounts object
     */
    const convertPaymentAmountsTableToObject = function ($content, isTabular) {

        let paymentAmounts = {};

        if (isTabular) {
            let tableRows = $content.get(0).querySelectorAll('tr');

            try {
                tableRows.forEach(row => {
                    let loanNumber = row.querySelector('[data-style-field-name="Loan_Number__c"]').innerText;
                    let interestRate = row.querySelector('[data-style-field-name="genesis__Interest_Rate__c"]').innerText;
                    let principal = row.querySelector('[data-style-field-name="Principal_To_Be_Paid__c"] input');
                    let interest = row.querySelector('[data-style-field-name="Interest_To_Be_Paid__c"] input');
                    let fees = row.querySelector('[data-style-field-name="Fees_To_Be_Paid__c"] input');

                    paymentAmounts[loanNumber] = {};

                    paymentAmounts[loanNumber][INTEREST_RATE_TXT] = parseFloat(interestRate).toFixed(2);

                    paymentAmounts[loanNumber][PRINCIPAL_TXT] = {};
                    paymentAmounts[loanNumber][PRINCIPAL_TXT][VALUE_TXT] = (0).toFixed(2);
                    paymentAmounts[loanNumber][PRINCIPAL_TXT][HTML_TXT] = principal;

                    paymentAmounts[loanNumber][INTEREST_TXT] = {};
                    paymentAmounts[loanNumber][INTEREST_TXT][VALUE_TXT] = (0).toFixed(2);
                    paymentAmounts[loanNumber][INTEREST_TXT][HTML_TXT] = interest;

                    paymentAmounts[loanNumber][FEES_TXT] = {};
                    paymentAmounts[loanNumber][FEES_TXT][VALUE_TXT] = (0).toFixed(2);
                    paymentAmounts[loanNumber][FEES_TXT][HTML_TXT] = fees;
                });

            } catch (error) {
                console.error(error);
            }
        } else {
            let cards = $content.get(0).querySelectorAll('.record-content');

            try {
                cards.forEach(card => {
                    let loanNumber = card.querySelector('[data-style-field-name="Loan_Number__c"] [data-style-id="card-view-value"]').innerText;
                    let interestRate = card.querySelector('[data-style-field-name="genesis__Interest_Rate__c"] [data-style-id="card-view-value"]').innerText;
                    let principal = card.querySelector('[data-style-field-name="Principal_To_Be_Paid__c"] input');
                    let interest = card.querySelector('[data-style-field-name="Interest_To_Be_Paid__c"] input');
                    let fees = card.querySelector('[data-style-field-name="Fees_To_Be_Paid__c"] input');

                    paymentAmounts[loanNumber] = {};

                    paymentAmounts[loanNumber][INTEREST_RATE_TXT] = parseFloat(interestRate).toFixed(2);

                    paymentAmounts[loanNumber][PRINCIPAL_TXT] = {};
                    paymentAmounts[loanNumber][PRINCIPAL_TXT][VALUE_TXT] = (0).toFixed(2);
                    paymentAmounts[loanNumber][PRINCIPAL_TXT][HTML_TXT] = principal;

                    paymentAmounts[loanNumber][INTEREST_TXT] = {};
                    paymentAmounts[loanNumber][INTEREST_TXT][VALUE_TXT] = (0).toFixed(2);
                    paymentAmounts[loanNumber][INTEREST_TXT][HTML_TXT] = interest;

                    paymentAmounts[loanNumber][FEES_TXT] = {};
                    paymentAmounts[loanNumber][FEES_TXT][VALUE_TXT] = (0).toFixed(2);
                    paymentAmounts[loanNumber][FEES_TXT][HTML_TXT] = fees;
                });

            } catch (error) {
                console.error(error);
            }
        }

        return sortObject(paymentAmounts);
    }

    /**
     * Converts the outstanding amounts table into an outstanding amounts JS object.
     * 
     * @param {any} $content table element of the outstanding amounts table
     * @returns the outstanding amounts object
     */
    const convertOutstandingAmountsTableToObject = function ($content, isTabular) {

        let outstandingAmounts = {};

        if (isTabular) {
            let tableRows = $content.get(0).querySelectorAll('tr');

            try {
                tableRows.forEach(row => {

                    let loanNumber = row.querySelector('[data-style-field-name="Loan_Number__c"]').innerText;
                    let interestRate = row.querySelector('[data-style-field-name="genesis__Interest_Rate__c"]').innerText.replace(NUMBER_REGEX, '');
                    let principal = row.querySelector('[data-style-field-name="Principal_Advanced__c"]').innerText.replace(NUMBER_REGEX, '');
                    let interest = row.querySelector('[data-style-field-name="Accrued_Interest__c"]').innerText.replace(NUMBER_REGEX, '');
                    let fees = row.querySelector('[data-style-field-name="Fees__c"]').innerText.replace(NUMBER_REGEX, '');

                    outstandingAmounts[loanNumber] = {};
                    outstandingAmounts[loanNumber][INTEREST_RATE_TXT] = parseFloat(interestRate).toFixed(2);
                    outstandingAmounts[loanNumber][PRINCIPAL_TXT] = parseFloat(principal).toFixed(2);
                    outstandingAmounts[loanNumber][INTEREST_TXT] = parseFloat(interest).toFixed(2);
                    outstandingAmounts[loanNumber][FEES_TXT] = parseFloat(fees).toFixed(2);
                });
            } catch (error) {
                console.error(error);
            }
        } else {

            let cards = $content.get(0).querySelectorAll('.record-content');

            try {
                cards.forEach(card => {

                    let loanNumber = card.querySelector('[data-style-field-name="Loan_Number__c"] [data-style-id="card-view-value"]').innerText;
                    let interestRate = card.querySelector('[data-style-field-name="genesis__Interest_Rate__c"] [data-style-id="card-view-value"]').innerText.replace(NUMBER_REGEX, '');
                    let principal = card.querySelector('[data-style-field-name="Principal_Advanced__c"] [data-style-id="card-view-value"]').innerText.replace(NUMBER_REGEX, '');
                    let interest = card.querySelector('[data-style-field-name="Accrued_Interest__c"] [data-style-id="card-view-value"]').innerText.replace(NUMBER_REGEX, '');
                    let fees = card.querySelector('[data-style-field-name="Fees__c"] [data-style-id="card-view-value"]').innerText.replace(NUMBER_REGEX, '');

                    outstandingAmounts[loanNumber] = {};
                    outstandingAmounts[loanNumber][INTEREST_RATE_TXT] = parseFloat(interestRate).toFixed(2);
                    outstandingAmounts[loanNumber][PRINCIPAL_TXT] = parseFloat(principal).toFixed(2);
                    outstandingAmounts[loanNumber][INTEREST_TXT] = parseFloat(interest).toFixed(2);
                    outstandingAmounts[loanNumber][FEES_TXT] = parseFloat(fees).toFixed(2);
                });
            } catch (error) {
                console.error(error);
            }

        }

        return sortObject(outstandingAmounts);
    }


    /**
     * Injects the payment amounts in the respective fields in the payments table in portal UI.
     * 
     * @param {any} paymentAmounts the payment amounts JS object
     */
    const injectPaymentSpreadInUI = function (paymentAmounts) {
        try {
            Object.keys(paymentAmounts).forEach(key => {
                //Validating -0.00s
                if(paymentAmounts[key].principal.value === "-0.00"){
                    paymentAmounts[key].principal.value = "0.00";
                }
                if(paymentAmounts[key].interest.value === "-0.00"){
                    paymentAmounts[key].interest.value = "0.00";
                }
                if(paymentAmounts[key].fees.value === "-0.00"){
                    paymentAmounts[key].fees.value = "0.00";
                }
                // set the principal
                setNativeValue(paymentAmounts[key].principal.html, paymentAmounts[key].principal.value);
                // set the interest
                setNativeValue(paymentAmounts[key].interest.html, paymentAmounts[key].interest.value);
                // set the fees
                setNativeValue(paymentAmounts[key].fees.html, paymentAmounts[key].fees.value);
            });
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * Processed object to generate the payment spread.
     * 
     * @param {any} outstandingAmounts the outstanding amounts JS object
     * @param {any} paymentAmounts the payment amounts JS object
     * @param {any} total the total amount the user is entering in the payment amount input field
     */
    const processSpread = function (outstandingAmounts, paymentAmounts, total) {

        try {
            // spread fees
            if (total > 0) {
                Object.keys(paymentAmounts).forEach(key => {
                    if (outstandingAmounts[key].fees > 0) {
                        paymentAmounts[key].fees.value = parseFloat(Math.min(outstandingAmounts[key].fees, total)).toFixed(2);

                        total -= paymentAmounts[key].fees.value;
                    }
                });
            }

            // spread interest
            if (total > 0) {
                Object.keys(paymentAmounts).forEach(key => {
                    if (outstandingAmounts[key].interest > 0) {
                        paymentAmounts[key].interest.value = parseFloat(Math.min(outstandingAmounts[key].interest, total)).toFixed(2);

                        total -= paymentAmounts[key].interest.value;
                    }
                });
            }

            // spread principal
            if (total > 0) {
                Object.keys(paymentAmounts).forEach(key => {
                    if (outstandingAmounts[key].principal > 0) {
                        paymentAmounts[key].principal.value = parseFloat(Math.min(outstandingAmounts[key].principal, total)).toFixed(2);

                        total -= paymentAmounts[key].principal.value;
                    }
                });
            }

        } catch (error) {
            console.error(error);
        }

        injectPaymentSpreadInUI(paymentAmounts);
    }

    /**
     * Sets up the payment spread in the portal UI (called from portal).
     * 
     * @param {any} outstandingTableActor the actor name of the outstanding amounts table actor
     * @param {any} paymentTableActor the actor name of the payment amounts table actor
     * @param {any} paymentAmountActor the actor name of the total payment amount input actor
     */
    const spread = function (outstandingTableActor, paymentTableActor, paymentAmountActor) {

        let isTabular = true;

        let $paymentAmountInput = $(
            `[data-style-actor-name='${paymentAmountActor}'] [data-style-field-name='PaymentAmount'] input`
        );

        let $userPaymentContent = $(
            `[data-style-actor-name='${paymentTableActor}'] table tbody`
        );

        if ($userPaymentContent[0] == undefined) {
            isTabular = false;

            $userPaymentContent = $(
                `[data-style-actor-name='${paymentTableActor}'] [data-style-id='sort-control'] + [data-style-id='grid-container']`
            );
        }

        let $outstandingPaymentContent = $(
            `[data-style-actor-name='${outstandingTableActor}'] table tbody`
        );

        if ($outstandingPaymentContent[0] == undefined) {
            isTabular = false;

            $outstandingPaymentContent = $(
                `[data-style-actor-name='${outstandingTableActor}'] [data-style-id='sort-control'] + [data-style-id='grid-container']`
            );
        }

        let paymentObject = convertPaymentAmountsTableToObject($userPaymentContent, isTabular);
        let outstandingObject = convertOutstandingAmountsTableToObject($outstandingPaymentContent, isTabular);

        let amount = parseFloat($paymentAmountInput.val().replace(NUMBER_REGEX, ''));

        processSpread(outstandingObject, paymentObject, amount);

        $callbackAction = $('[data-style-action-name="growerAutoFillCallRecordAction"]');
        $callbackAction.click();
    }

    return {
        spread: spread
    };
})();

(function (portalext, $) {
    portalext.spread = payment.spread;
})((window.portalext = window.portalext || {}));