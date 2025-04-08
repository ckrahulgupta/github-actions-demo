import { LightningElement, api, wire, track } from 'lwc';
import getMyProgramDetails from '@salesforce/apex/UpdateMyProgramController.getMyProgramDetails';

export default class EditMyProgram extends LightningElement {

    @api recordId;

    @track error;
    myProgramData;
    @track rateCardSetupDetailsList;

    @track trancheNamesList={"Master Note Rate (A)":1,
                            "Special Term Sub-Tranche (B)":2,
                            "Special Term Sub-Tranche (C)":3,
                            "Special Term Sub-Tranche (D)":4,
                            "Special Term Sub-Tranche (E)":5,
                            "Special Term Sub-Tranche (F)":6,
                            "Special Term Sub-Tranche (G)":7,
                            "Special Term Sub-Tranche (H)":8,
                        };

    counter=0;

    
    @wire(getMyProgramDetails, {myProgramId: '$recordId'})
    wireMyProgramDetails({error, data}){
        if(data){
            // console.log(data);
            this.myProgramData=data.rateCardHeader;
            let rateCardSetupDetails=data.rateCardDetails;
            // console.log('hithere',this.rateCardSetupDetails);
              

            const groupedData = rateCardSetupDetails.reduce((result, item) => {
                // Create a key based on the Special_Term_Reference__c
                const key = item.Special_Term_Reference__c;
                
                // If the key doesn't exist, initialize an empty array
                if (!result[key]) {
                    result[key] = [];
                }
                
                const existingRecord = result[key].find(existingItem => existingItem.Id === item.Id);

                if(!existingRecord){
                    // Push the current item to the correct group
                    result[key].push(item);
                }
                
                return result;
            }, {});

            this.rateCardSetupDetailsList = Object.keys(groupedData).map(key => {
                const group = groupedData[key];
                
                // Take the first record from the group to extract Description__c and Has_Billing_Date__c
                const { Description__c, Has_Billing_Date__c,Billing_Date__c } = group[0];

                const groupId=this.trancheNamesList[key] || 1;
                const groupName= this.trancheNamesList.hasOwnProperty(key)?key: 'Master Note Rate (A)';
                
                return {
                    Id:groupId,
                    Name: groupName,
                    StepRates: group,
                    Description__c,  // Add the description
                    Has_Billing_Date__c, // Add the billing information
                    Billing_Date__c  
                };
            });

            // console.log('hello',JSON.stringify(this.rateCardSetupDetailsList))
        }
        else if(error){
            this.error=error;
            // console.log(this.error);
        }
    }

    // masterNoteRateData = [
    //     {
    //         Id: 1,
    //         Name: 'Master Note Rate (A)',
    //         isChecked: false,
    //         description: 'Seeds',
    //         data: [{
    //             startDate: '12/31/2024',
    //             endDate: '6/30/2025',
    //             growerRate: '15.00',
    //             growerRateType: 'Fixed',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '0.60',
    //             cfaParticipation: '1.26'
    //         },
    //         {
    //             startDate: '7/1/2025',
    //             endDate: '8/31/2025',
    //             growerRate: '16.00',
    //             growerRateType: 'Variable',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '6.76',
    //             cfaParticipation: '1.26'
    //         }]
    //     },
    //     {
    //         Id: 2,
    //         Name: 'Special Term Sub-Tranche (B)',
    //         isChecked: false,
    //         description: 'Equipment',
    //         data: [{
    //             startDate: '12/31/2024',
    //             endDate: '6/30/2025',
    //             growerRate: '15.00',
    //             growerRateType: 'Fixed',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '3.76',
    //             cfaParticipation: '1.26'
    //         },
    //         {
    //             startDate: '7/1/2025',
    //             endDate: '8/31/2025',
    //             growerRate: '16.00',
    //             growerRateType: 'Variable',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '6.76',
    //             cfaParticipation: '1.26'
    //         },
    //         {
    //             startDate: '9/1/2025',
    //             endDate: '12/31/2025',
    //             growerRate: '16.00',
    //             growerRateType: 'Variable',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '6.76',
    //             cfaParticipation: '1.26'
    //         }]
    //     },
    //     {
    //         Id: 3,
    //         Name: 'Special Term Sub-Tranche (C)',
    //         isChecked: true,
    //         description: 'Equipment',
    //         billingDate: '8/31/2025',
    //         data: [{
    //             startDate: '12/31/2024',
    //             endDate: '6/30/2025',
    //             growerRate: '15.00',
    //             growerRateType: 'Fixed',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '3.76',
    //             cfaParticipation: '1.26'
    //         },
    //         {
    //             startDate: '7/1/2025',
    //             endDate: '8/31/2025',
    //             growerRate: '16.00',
    //             growerRateType: 'Variable',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '6.76',
    //             cfaParticipation: '1.26'
    //         },
    //         {
    //             startDate: '9/1/2025',
    //             endDate: '12/31/2025',
    //             growerRate: '16.00',
    //             growerRateType: 'Variable',
    //             dealerSubsidy: '0.00',
    //             dealerPremium: '6.76',
    //             cfaParticipation: '1.26'
    //         }]
    //     }

    // ];

    // columns = [
    //     {
    //         label: 'Start Date', 
    //         fieldName: 'startDate', 
    //         type: 'date', 
    //         editable: true, 
    //         typeAttributes: {
    //                         day: '2-digit',
    //                         month: '2-digit',
    //                         year: 'numeric'
    //                     },
    //         formatter: this.dateFormatter
                                                                                                    
    //     },
    //     {
    //         label: 'End Date', 
    //         fieldName: 'endDate', 
    //         type: 'date', 
    //         editable: true, 
    //         typeAttributes: {
    //                         day: '2-digit',
    //                         month: '2-digit',
    //                         year: 'numeric',
    //                     },
    //         formatter: this.dateFormatter
    //     },
    //     { label: 'Grower Rate ', fieldName: 'growerRate', type: 'percent', editable: true },
    //     { label: 'Grower Rate Type', fieldName: 'growerRateType', type: 'text', editable: true },
    //     { label: 'Dealer Subsidy ', fieldName: 'dealerSubsidy', type: 'percent', editable: true },
    //     { label: 'Dealer Premium ', fieldName: 'dealerPremium', type: 'percent', editable: true },
    //     { label: 'CFA Participation ', fieldName: 'cfaParticipation', type: 'percent', editable: true },
    //     {
    //         type: 'action',
    //         typeAttributes: {
    //             rowActions: [
    //                 { label: 'Delete', name: 'delete' }
    //             ]
    //         }
    //     }
    // ];
    columns = [
        {
            label: 'Start Date', 
            fieldName: 'Start_Date__c', 
            type: 'date', 
            editable: true, 
            typeAttributes: {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric'
                        },
            formatter: this.dateFormatter
                                                                                                    
        },
        {
            label: 'End Date', 
            fieldName: 'End_Date__c', 
            type: 'date', 
            editable: true, 
            typeAttributes: {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric',
                        },
            formatter: this.dateFormatter
        },
        { label: 'Grower Rate ', fieldName: 'genesis__Interest_Rate__c', type: 'percent', editable: true },
        { label: 'Grower Rate Type', fieldName: 'Interest_Rate_Type__c', type: 'text', editable: true },
        { label: 'Dealer Subsidy ', fieldName: 'Participation_Percentage_Dealer_Subsidy__c', type: 'percent', editable: true },
        { label: 'Dealer Premium ', fieldName: 'Participation_Percentage_Dealer__c', type: 'percent', editable: true },
        { label: 'CFA Participation ', fieldName: 'Participation_Percentage_CFA__c', type: 'percent', editable: true },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    // Getter to return formatted data
    // get formattedMasterNoteRateData() {
    //     return this.masterNoteRateData.map(item => {
    //         return {
    //             ...item,
    //             data: item.data.map(eachRate => ({
    //                 ...eachRate,
    //                 startDate: this.formatDate(eachRate.startDate), // Format start date
    //                 endDate: this.formatDate(eachRate.endDate)      // Format end date
    //             })),
    //             billingDate: item.billingDate ? this.formatDate(item.billingDate) : null // Format billing date if it exists
    //         };
    //     });
    // }

    // Utility function to format date to MM/DD/YYYY
    // formatDate(date) {
    //     const d = new Date(date);
    //     const month = (d.getMonth() + 1).toString().padStart(2, '0'); // +1 because months are 0-indexed
    //     const day = d.getDate().toString().padStart(2, '0');
    //     const year = d.getFullYear();
    //     return `${month}/${day}/${year}`;
    // }



    // @track isChecked;
    // handleCheckboxChange(event) {

    //     console.log(event);
    //     console.log(event.target.checked);

    //     const itemId= event.target.dataset.id;
    //     console.log(itemId);
    //     const isChecked = event.target.checked;
    //     const item = this.masterNoteRateData.find(note => note.Id === parseInt(itemId));
    //     if(item){
    //         item.isChecked = isChecked;
    //         console.log(item.isChecked);
    //         if (isChecked && !item.billingDate) {
    //             item.billingDate = this.formatDate(new Date());
    //         }
    //         this.masterNoteRateData = [...this.masterNoteRateData];
    //     }

    // }
    handleCheckboxChange(event) {

        console.log(event);
        console.log(event.target.checked);

        const itemId= event.target.dataset.id;
        const isChecked = event.target.checked;
        const item = this.rateCardSetupDetailsList.find(note => note.Id === parseInt(itemId));
        if(item){
            item.Has_Billing_Date__c = isChecked;
            if (isChecked && !item.Billing_Date__c) {
                item.Billing_Date__c = this.formatDate(new Date());
            }
            this.rateCardSetupDetailsList = [...this.rateCardSetupDetailsList];
        }

    }

    // connectedCallback() {
    //     console.log('recordId',this.recordId);
    //     // getMyProgramDetails({});
    //     this.masterNoteRateData = this.masterNoteRateData.map(item => {
    //         return {
    //             ...item,
    //             data: item.data.map(eachRate => {
    //                 return {
    //                     ...eachRate,
    //                     growerRate: eachRate.growerRate / 100,
    //                     dealerSubsidy: eachRate.dealerSubsidy / 100,
    //                     dealerPremium: eachRate.dealerPremium / 100,
    //                     cfaParticipation: eachRate.cfaParticipation / 100
    //                 };
    //             })

    //         };
    //     });


    // }
}