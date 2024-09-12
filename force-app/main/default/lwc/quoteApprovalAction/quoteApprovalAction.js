import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteLineIds from '@salesforce/apex/QuoteApprovalActionController.getQuoteLineIds';
import approveQuoteLine from '@salesforce/apex/QuoteApprovalActionController.approveQuoteLine';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QuoteApprovalAction extends NavigationMixin(LightningElement) {

    @api
    recordId;

    isExecuting = false;
    quoteLines = [];

    @api async invoke() {
        if (this.isExecuting) {
            let event = new ShowToastEvent({
                title: 'Processing',
                message: 'We are still processing your request',
            });
            this.dispatchEvent(event);
            return;
        }

        this.isExecuting = true;
        let quoteLineIds = await this.getQuoteLineIds();
        let results = await quoteLineIds.reduce( (previousPromise, quoteLineId) => {
            return previousPromise.then(() => {
              return approveQuoteLine({ quoteLineId : quoteLineId});
            });
        }, Promise.resolve());

        if(results) {
            let event = new ShowToastEvent({
                title: 'Success!',
                message: 'Quote Lines have been submitted for approval!',
            });
            this.dispatchEvent(event);

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'SBQQ__Quote__c',
                    actionName: 'view'
                }
            });
        }
        this.isExecuting = false;
    }

    getQuoteLineIds() {
        return new Promise((resolve, reject) => {
            getQuoteLineIds({ quoteId : this.recordId}).then(result => {
                if(result) {
                    resolve(result);
                }
            }).catch(error => {
                console.log(error);
                reject(error);
            });
        }); 
    }
}