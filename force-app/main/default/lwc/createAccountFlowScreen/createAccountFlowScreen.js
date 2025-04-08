import { LightningElement, api, track, wire } from 'lwc';
import getRecordTypeList from '@salesforce/apex/CreateAccountController.getRecordTypeList';


export default class CreateAccountFlowScreen extends LightningElement {
    @api recordId;
    recordTypeList = [];
    @api selectedRecordType;

    @wire(getRecordTypeList,{recordId:'$recordId'})
    getRecordTypes({ data, error  }) {
        if (data) {
           this.recordTypeList = data.map((recordType) => ({
            label: recordType.Name,
            value: recordType.Id
        }));
        } else if (error) {
            console.log(error);
        }
    }

    handleChange(e){
        this.selectedRecordType = e.detail.value;
        console.log(this.selectedRecordType);
    }
}