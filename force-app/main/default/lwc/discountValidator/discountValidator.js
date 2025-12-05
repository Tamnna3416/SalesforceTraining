import { LightningElement, api } from 'lwc';
import { updateRecord ,getRecordNotifyChange} from 'lightning/uiRecordApi';
import validateDealApex from '@salesforce/apex/DiscountValidator.validateDeal';
import submitApprovalApex from '@salesforce/apex/DiscountValidator.submitForApproval';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import DISCOUNT_FIELD from '@salesforce/schema/Opportunity.Discount__c';

export default class DiscountValidator extends LightningElement {

    @api recordId;   
    discount;
    result;
    showApprovalButton = false;


    handleDiscountChange(event) {
        this.discount = event.target.value;
    }

    validateDeal() {

        validateDealApex({
            oppId: this.recordId,
            discount: parseFloat(this.discount)
        })
        .then(res => {
            this.result = res;
             
           this.showApprovalButton = false;

             if (res.status === 'AUTO_APPROVED') {
                this.updateDiscountField();
            }
            if (res.status === 'APPROVAL_NEEDED') {
                this.showApprovalButton = true;
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    updateDiscountField() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[DISCOUNT_FIELD.fieldApiName] = this.discount;

        updateRecord({ fields })
            .then(() => {
                console.log('Discount saved');
                getRecordNotifyChange([{ recordId: this.recordId }]);
            });l
        }

    submitForApproval()
    {
        submitApprovalApex({ oppId: this.recordId })
        .then(result => {
             this.showApprovalButton = false;
        })
        .catch(error => {
            console.error(error);
        });
    }

    get approvalButtonStyle() {
    return this.showApprovalButton ? '' : 'display:none;';
}
    
    get isBlocked() {
        return this.result?.status === 'BLOCKED';
    }

    get isApprovalNeeded() {
        return this.result?.status === 'APPROVAL_NEEDED';
    }

    get isApproved() {
        return this.result?.status === 'AUTO_APPROVED';
    }
}