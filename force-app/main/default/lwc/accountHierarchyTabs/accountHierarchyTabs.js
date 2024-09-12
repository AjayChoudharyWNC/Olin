import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import AccountType from '@salesforce/schema/Account.Account_Type_Text_Only__c';
import IsSoldTo from '@salesforce/schema/Account.Sold_To__c'
import IsShipTo from '@salesforce/schema/Account.Ship_To__c'
import modalCSS from "@salesforce/resourceUrl/ModalCSS";
import { loadStyle } from "lightning/platformResourceLoader";
const FIELDS = [
    AccountType, IsShipTo, IsSoldTo
];

export default class AccountHierarchyTabs extends LightningElement {
    @api recordId;
    showShipTo = false;
    showSoldTo = false;
    isFirstTimeSoldTo = true;
    isFirstTimeShipTo = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    loadFields({ error, data }) {
        if (error) {

        } else if (data) {
            let accountType = getFieldValue(data, AccountType);
            let isSoldTo = getFieldValue(data, IsSoldTo);
            let isShipTo = getFieldValue(data, IsShipTo);
            if (accountType != 'Sold To' && accountType != 'Parent' && accountType != 'Prospect') {
                this.showShipTo = true;
            }
            if (accountType == 'Sold To & Ship To' || accountType == 'Sold To' || accountType == 'Parent') {
                this.showSoldTo = true;
            }
            if(accountType == 'Prospect'){
                if(isSoldTo == true){
                    this.showSoldTo = true;
                }
                if(isShipTo == true){
                    this.showShipTo = true;
                }
            }
            if((this.showSoldTo && this.showShipTo) || (!this.showShipTo)){
                this.isFirstTimeSoldTo = false;
            }
            if(!this.showSoldTo){
                this.isFirstTimeShipTo = false;
            }
        }
    }

    connectedCallback() {
        loadStyle(this, modalCSS);
    }

    handleActiveShipTo = () => {
        if (this.template.querySelector('c-account-hierarchy-cmp') && this.isFirstTimeShipTo) {
            //this.template.querySelector('c-account-hierarchy-cmp').getAccounts();
            this.isFirstTimeShipTo = false;
        }
    }

    handleActiveSoldTo = () => {
        if (this.template.querySelector('c-account-hierarchy-cmp') && this.isFirstTimeSoldTo) {
            //this.template.querySelector('c-account-hierarchy-cmp').getAccounts();
            this.isFirstTimeSoldTo = false;
        }
    }

}