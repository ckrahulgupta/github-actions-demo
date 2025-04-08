import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountName from'@salesforce/apex/UpdateDealerRelationAPI.getAccountName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModifyDealerRelation extends NavigationMixin(LightningElement) {
    
    defaultStates = {
        start: false,
        update: false,
        remove: false
    };
    @track currentState = 'start';
    @track states={
        start: true,
        update: false,
        remove: false
    };
    options = [
        { label: 'Update Dealer Relation', value: 'update' },
        { label: 'Remove Dealer Relation', value: 'remove'},
    ];

    handleOptionChange(event) {
        this.currentState = event.target.value;
    }
    handleContinue(){
        if(this.currentState!='update' && this.currentState != 'remove'){
            this.displayToast('Error','Please choose required option','error');
        }
        else{
            this.states = this.defaultStates;
            this.states[this.currentState] = true;
        }

    }
    @api recordId;
    @track error
    accountDetails;

    // to get the account records
    @wire(getAccountName,{recordId:'$recordId'})
    wireAccountData({error,data}){
        if (data) {
            this.accountDetails=data;
        } else if (error) {
            this.error = error;
        }
    }  
    displayToast(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

   
}