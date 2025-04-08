import { LightningElement, wire, track ,api} from 'lwc';
import fetchSADetails from '@salesforce/apex/SalesAgentAssignmentHandler.fetchSADetails';
import updateSAADetails from '@salesforce/apex/SalesAgentAssignmentHandler.updateSAADetails';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
 
export default class ChooseSalesAgents extends LightningElement {
    @api recordId;
    @track mapData= [];
    @track error;
 
    @track value=[];
 
    @wire(fetchSADetails, {accId: '$recordId'})
    
    wireMapData({error, data}) {
        if (data) {
            var conts = data.isRelatedMap;
            for(var key in conts){
                this.mapData.push({value:key, label:data.accVsIdMap[key].Name});
                if(conts[key]==true){
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
        let targetUrl = window.location.origin + '/lightning/r/Account/' + this.recordId + '/view' ;
        updateSAADetails({selectedSalesAgentsList: this.value, saAdminAccId: this.recordId})
        .then(this.displayToast()).then(this.dispatchEvent(new CloseActionScreenEvent())).then(window.location.href=targetUrl)
    }
    
    displayToast(){
        const evt = new ShowToastEvent({
            title: 'Operation Successful',
            message: 'Selected Sales Agents has been assigned to the Sales Agent Admin',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
 
}