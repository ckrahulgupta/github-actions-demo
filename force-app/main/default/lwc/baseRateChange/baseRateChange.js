import { LightningElement, track, wire, api } from 'lwc';
import getBaseRateOptions from '@salesforce/apex/BaseRateChangeController.getBaseRateOptions';
import getCurrentInterestRate from '@salesforce/apex/BaseRateChangeController.getCurrentInterestRate';
import updateInterestRate from '@salesforce/apex/BaseRateChangeController.updateInterestRate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BaseRateChange extends LightningElement {
    @track value = 'inProgress';
    @track showDynamicField = false;
    @track dynamicFieldValue = ''; // This should be a string or null
    @track interestRates = {}; // Store all interest rates
    @track newInterestRate = '';
    @track newInterestRateError = '';
    @track newInterestValue = '';
    @track options = [];

    @wire(getBaseRateOptions)
    wiredBaseRateOptions({ error, data }) {
        if (data) {
            this.options = data.map(option => ({ label: option.label, value: option.value }));
            console.log('Options loaded: ', this.options);
        } else if (error) {
            console.error('Error loading options:', error);
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.showDynamicField = true;
        // Check for null or undefined before accessing interestRates
        this.dynamicFieldValue = this.interestRates[this.value] || '';  // Set empty string if null
        this.newInterestValue = '';
    }

    @wire(getCurrentInterestRate)
    getInterestRate({ error, data }) {
        if (data) {
            this.interestRates = data;
            console.log('Interest rates loaded: ', this.interestRates);
        } else if (error) {
            console.error('Error loading interest rates:', error);
        }
    }

    handleSave() {
        const newInterestRate = this.template.querySelector("[data-lightning-input='New Index Rate (%)']").value;
        const currentInterestRate = this.template.querySelector("[data-lightning-input='Current Index Rate (%)']").value;
        if (!newInterestRate) {
            this.newInterestRateError = 'Please enter a value for the new interest rate.';
            return;
        }
        const regex = /^\d+(\.\d{0,2})?$/;  // Allows up to two decimal places
        if (!regex.test(newInterestRate)) {
            this.newInterestRateError = 'Please enter a positive decimal number as a interest rate. Up to two decimal places are allowed.';
            return;
        }
        if (newInterestRate == currentInterestRate) {
            this.newInterestRateError = 'Please change the interest rate, current rate and new rate cannot be same.';
            return;
        }
        this.newInterestRateError = '';
        const selectedRateLabel = this.options.find(option => option.value === this.value)?.label;
        this.showToast(selectedRateLabel);

        updateInterestRate({ selectedRate: this.value, newInterestRate: newInterestRate, currentInterestRate: currentInterestRate })
            .then(() => {
            })
            .catch((error) => {
                this.displayToast('Operation Failed', 'Rate could not be updated', 'error');
                console.error('Error updating custom metadata:', error);
            });
    }

    showToast(selectedRateLabel) {
        const toastTitle = `${selectedRateLabel} has been updated`; // Dynamic toast message
        const toastMessage = 'Please wait for some time while rate cards are updated in the background. You will receive a notification on completion.';
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: 'success',
        });
        this.dispatchEvent(event);
    }

    displayToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}