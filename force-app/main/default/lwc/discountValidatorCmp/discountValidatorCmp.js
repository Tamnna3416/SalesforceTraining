import { LightningElement, api, wire } from 'lwc';
import validateDiscount from '@salesforce/apex/DiscountValidator.validateDeal';
import { getRecord } from 'lightning/uiRecordApi';
import DISCOUNT_FIELD from '@salesforce/schema/Opportunity.Discount__c';

export default class DiscountValidatorCmp extends LightningElement {
    @api recordId;
    discount;
    result;

    @wire(getRecord, { recordId: '$recordId', fields: [DISCOUNT_FIELD] })
    opp({ data }) {
        if (data) {
            this.discount = data.fields.Discount__c.value;
        }
    }

    handleValidate() {
        validateDiscount({ opportunityId: this.recordId, discount: this.discount })
            .then(result => {
                this.result = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    get badgeClass() {
        if (!this.result) return '';
        return this.result === 'BLOCKED'
            ? 'slds-badge slds-theme_error'
            : this.result === 'APPROVAL_NEEDED'
            ? 'slds-badge slds-theme_warning'
            : 'slds-badge slds-theme_success';
    }
}