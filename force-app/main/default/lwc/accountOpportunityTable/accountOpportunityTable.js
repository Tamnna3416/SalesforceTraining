import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountOpportunityController.getAccounts';

export default class AccountOpportunityTable extends LightningElement {

    @track accounts = [];
    @track selectedOpportunities = [];
    @track selectedAccountName = '';

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Phone', fieldName: 'Phone' },
        {
            type: 'button',
            typeAttributes: { label: 'Expand', name: 'expand', variant: 'brand' }
        }
    ];

    oppColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Stage', fieldName: 'StageName' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date' }
    ];

    // Load Accounts
    @wire(getAccounts)
    wiredAccounts({ data }) {
        console.log('wiredAccounts');
        if (data) {
            this.accounts = data;
        }
    }

    handleRowAction(event) {
        console.log('Row Action: ' + event.detail.action.name);
        console.log('Row Action:---------');
        const row = event.detail.row;

        this.selectedAccountName = row.Name;
        this.selectedOpportunities = row.Opportunities;
    }
}