import { LightningElement, wire, track, api } from 'lwc';
import getPermissionSetList from '@salesforce/apex/EnableGrowerPortal.getPermissionSetList';
import updatePermissionSet from '@salesforce/apex/EnableGrowerPortal.updatePermissionSet';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class EnableGrower extends LightningElement {
    @api recordId;
    @track mapData = [];
    @track error;

    //@track 
    @track value = [];

    @wire(getPermissionSetList, { cntId: '$recordId' })
    wireMapData({data, error}) {
        if (data) {
            var conts = data.isRelatedMap;
            for (var key in conts) {
                this.mapData.push({ value: key, label: key });
                if (conts[key] == true) {
                    this.value.push(key);
                }
            }
        } else if (error) {
            this.error = error;
        }
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

    handleSave(e) {
        e.preventDefault();    
        if (this.value.length === 0) {
            this.showToast('Error', 'Please select at least one portal to enable.', 'error');
            return; 
        }
        let targetUrl = window.location.origin + '/lightning/r/Contact/' + this.recordId + '/view' ;
        updatePermissionSet({selectedPermissionSetList: this.value, contactId: this.recordId})
            .then(() => {
                this.showToast('Success', 'Selected Permission Set has been assigned to the Grower', 'success')
                this.dispatchEvent(new CloseActionScreenEvent())
                window.location.href = targetUrl
            })
            .catch((error) => {
                this.errorMessage = error.body && error.body.message ? error.body.message : PortalConstants.SOMETHING_WENT_WRONG;
                this.showToast('Error', this.errorMessage, 'error');
                
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable',
        });
        this.dispatchEvent(evt);
    }

}