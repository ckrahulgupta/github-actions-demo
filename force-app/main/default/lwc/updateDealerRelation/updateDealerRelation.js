import { LightningElement,track,wire,api } from 'lwc';
import getDealerAccount from '@salesforce/apex/UpdateDealerRelationAPI.getDealerAccount';
import getEntityRole from'@salesforce/apex/UpdateDealerRelationAPI.getEntityRole';
import updateDealerRelation from '@salesforce/apex/UpdateDealerRelationAPI.updateDealerRelation';
import getExistingRelationship from '@salesforce/apex/UpdateDealerRelationAPI.fetchExistingRelationships';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UpdateDealerRelation extends LightningElement {
    @api dealerContactName;
    @api dealerContactId;
    @api parentId;
    @api parentAccountName;
    @api dealerContactEntityRole;
    @api dealerContactEntityRoleId;
    @api recordId;
    @track isChanged=false;
    @track isError = false;
    
    accountOptions = [];
    selectedAccountId = '';
    entityOptions=[];
    selectedEntityRole=[];
    existingRelationship=[];
    emptyRelationship=[];
    value=[];

    @wire(getExistingRelationship, {recordId:'$dealerContactId'})
    wiredExistingRelationship({error, data}) {
        if(data) {
            for(var key in data){
                this.existingRelationship.push(data[key].Id);
            }
            this.selectedEntityRole=this.existingRelationship;
            this.value=this.existingRelationship;
        } else if (error) {
            console.error('Error loading relationships:', error);
        }
    }

    //this method is used to fetch all the dealer name 
    @wire(getDealerAccount)
    wiredDealerAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map((acc) => ({
                label: acc.Name,
                value: acc.Id
            }));
        } else if (error) {
            console.error('Error loading dealer accounts:', error);
        }
    }
    handleAccountChange(event) {
        if(this.parentId != event.detail.value){
            this.selectedAccountId = event.detail.value;
            this.existingRelationship=this.emptyRelationship;
        } else if(this.parentId==event.detail.value) {
            this.selectedAccountId = event.detail.value;
            this.existingRelationship=this.value;
        }
    }  

    //to fetch all the entity role 
    @wire(getEntityRole,{recordId:'$dealerContactId'})
    wiredEnityRole({ error, data }) {
        if (data) {
            this.entityOptions = data.map((entity) => ({
                label: entity.Name,
                value: entity.Id
            }));
        } else if (error) {
            console.error('Error loading entity role:', error);
        }
    }

    connectedCallback(){
        this.selectedAccountId=this.parentId;
        this.selectedEntityRole=this.value;
    }

    // this will call when save button is hit
    handleSave() {

        let targetUrl = window.location.origin + '/lightning/r/Account/' + this.dealerContactId + '/view' ;
        console.log(this.selectedEntityRole);
        updateDealerRelation({accountId: this.dealerContactId, dealerId: this.selectedAccountId,entityRoleList: this.selectedEntityRole})
        .then(()=>{
            this.displayToast('Operation Successful','Dealer Contact has been updated successfully','success');
            this.dispatchEvent(new CloseActionScreenEvent());
            window.location.href=targetUrl;
        })
        .catch(error => {
            let errorMessage = 'Something Went Wrong';
            if ( error.body.message) {
                errorMessage =error.body.message;
            }
            this.displayToast('Operation Failed', errorMessage,'error');
        })
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

    handleRelationshipChange(event){
        let permissionedUserCount = 0;
        const permissionedUserList = ['Certified Lender',
                                    'Certified Lender Plus',
                                    'Sales Agent',
                                    'Sales Agent Plus',
                                    'Sales Agent Admin',
                                    'Inquiry Plus',
                                    'Inquiry',
                                    'Payment Administrator',
                                    'Field Staff Agent'];
        for(var rel of this.entityOptions){
            if(event.detail.value.includes(rel.value) && permissionedUserList.includes(rel.label)){
                permissionedUserCount += 1;
            }
        }
        console.log(permissionedUserCount);
        if(permissionedUserCount > 1){
            this.displayToast('Operation Failed', 'You cannot assign one person multiple permissioned user relationship.', 'error');
            this.isError = true;
        }else{
            this.isError = false;
            this.selectedEntityRole=event.detail.value;
        }    
    }
}