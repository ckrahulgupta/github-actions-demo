import { LightningElement,api } from 'lwc';
import deleteDealerRelation from '@salesforce/apex/UpdateDealerRelationAPI.deleteDealerRelation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RemoveDealerRelation extends LightningElement {
    @api recordId;
    @api dealerContactid;

    handleYesBtn(){
        let targetUrl = window.location.origin + '/lightning/r/Account/' + this.dealerContactid + '/view' ;
        deleteDealerRelation({accountId: this.dealerContactid})
        .then(this.displayToast('Operation Successful','Dealer Contact has been deleted successfully','success')).then(this.dispatchEvent(new CloseActionScreenEvent())).then(window.location.href=targetUrl)
    }
    handleNoBtn(){
        let targetUrl = window.location.origin + '/lightning/r/Account/' + this.dealerContactid + '/view' ;
        this.dispatchEvent(new CloseActionScreenEvent()).then(window.location.href=targetUrl)
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