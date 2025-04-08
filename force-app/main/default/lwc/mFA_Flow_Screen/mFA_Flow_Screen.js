import { api, LightningElement } from 'lwc';
import { FlowAttributeChangeEvent, FlowANavigationNextEvent, FlowANavigationFinishEvent, FlowNavigationBackEvent, FlowNavigationPauseEvent } from 'lightning/flowSupport'

export default class MFA_Flow_Screen extends LightningElement {
    @api availableActions = [];
    @api otp;

    handleChange = (event) =>{
        event.preventDefault();
        this.otp = event.target.value;
    }

}