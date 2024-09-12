import { LightningElement, api, track } from 'lwc';
import fetchAccounts from '@salesforce/apex/AccountHierarchyController.findAllHierarchyAccounts';
const COLLS = [
    {
        type: 'url', fieldName: 'AccountURL', label: 'Account Name', typeAttributes: { label: { fieldName: 'accountName' }, target: '_self' }
    },
    { type: 'text', fieldName: 'Account_Type_Text_Only__c', label: 'Account Type' },
    { type: 'text', fieldName: 'AccountNumber', label: 'Account Number' },
    { type: 'text', fieldName: 'OwnerName_R1__c', label: 'Owner Name' },
    { type: 'text', fieldName: 'LineOfBusiness_R1__c', label: 'Line Of Business' },
    { type: 'text', fieldName: 'BillingCity', label: 'Billing City' },
    { type: 'text', fieldName: 'BillingState', label: 'Billing State' },
    { type: 'text', fieldName: 'BillingCountry', label: 'Billing Country' }

];
export default class AccountHierarchyCmp extends LightningElement {

    gridColumns = COLLS;
    @track gridData = [];
    @track roles = {};
    currentExpandedRows = [];
    @api recordId;
    allData = [];
    @api accountType;
    isLoading = false;
    expandAll = false;
    chevronDownClass = 'slds-hide';
    chevronRightClass = 'slds-show';



    connectedCallback() {
        this.isLoading = true;
        console.log('==', this.accountType);
        this.getAccounts();
    }

    @api
    getAccounts = () => {
        fetchAccounts({ recordId: this.recordId, accountType: this.accountType })
            .then((result) => {
                let data = result;
                var finaldata = [];
                this.allData = result;
                var expandedRowInfo = [];
                for (var i = 0; i < data.length; i++) {
                    if (data[i].childAccounts) {
                        if (data[i].parentId == data[i].act.Id)
                            expandedRowInfo.push(data[i].act.Id);
                        this.roles[data[i].act.Id] = {
                            accountName: data[i].act.Name,
                            Id: data[i].act.Id,
                            AccountURL: '/' + data[i].act.Id,
                            Account_Type__c: data[i].act.Account_Type__c,
                            currentAccount: this.recordId == data[i].act.Id ? true : false,
                            Account_Type_Text_Only__c: data[i].act.Type_Icon__c ? data[i].act.Type_Icon__c : '',
                            AccountNumber: data[i].act.AccountNumber_R1__c ? data[i].act.AccountNumber_R1__c : '',
                            OwnerName_R1__c: data[i].act.OwnerName_R1__c ? data[i].act.OwnerName_R1__c : '',
                            LineOfBusiness_R1__c: data[i].act.LineOfBusiness_R1__c ? data[i].act.LineOfBusiness_R1__c : '',
                            BillingCity: data[i].act.BillingCity ? data[i].act.BillingCity : '',
                            BillingState: data[i].act.BillingState ? data[i].act.BillingState : '',
                            BillingCountry: data[i].act.BillingCountry ? data[i].act.BillingCountry : '',
                            Address: (data[i].act.BillingCity ? data[i].act.BillingCity + ' | ' : '') + (data[i].act.BillingState ? data[i].act.BillingState + ' | ' : '') + (data[i].act.BillingCountry ? data[i].act.BillingCountry : ''),
                            _children: []
                        };
                    } else {
                        this.roles[data[i].act.Id] = {
                            accountName: data[i].act.Name,
                            Id: data[i].act.Id,
                            AccountURL: '/' + data[i].act.Id,
                            Account_Type__c: data[i].act.Account_Type__c,
                            currentAccount: this.recordId == data[i].act.Id ? true : false,
                            Account_Type_Text_Only__c: data[i].act.Type_Icon__c ? data[i].act.Type_Icon__c : '',
                            AccountNumber: data[i].act.AccountNumber_R1__c ? data[i].act.AccountNumber_R1__c : '',
                            OwnerName_R1__c: data[i].act.OwnerName_R1__c ? data[i].act.OwnerName_R1__c : '',
                            LineOfBusiness_R1__c: data[i].act.LineOfBusiness_R1__c ? data[i].act.LineOfBusiness_R1__c : '',
                            BillingCity: data[i].act.BillingCity ? data[i].act.BillingCity : '',
                            BillingState: data[i].act.BillingState ? data[i].act.BillingState : '',
                            BillingCountry: data[i].act.BillingCountry ? data[i].act.BillingCountry : '',
                            Address: (data[i].act.BillingCity ? data[i].act.BillingCity + ' | ' : '') + (data[i].act.BillingState ? data[i].act.BillingState + ' | ' : '') + (data[i].act.BillingCountry ? data[i].act.BillingCountry : '')
                        };
                    }
                }
                for (var i = 0; i < data.length; i++) {
                    if (data[i].act.ParentId) {
                        if (this.roles[data[i].act.ParentId]) {
                            this.roles[data[i].act.ParentId]._children.push(this.roles[data[i].act.Id]);
                            this.roles[data[i].act.ParentId].hasChildren = this.expandAll;
                        }
                    }
                }
                for (var i = 0; i < data.length; i++) {
                    if (data[i].sameChildShipToAccounts) {
                        for (var j = 0; j < data[i].sameChildShipToAccounts.length; j++) {
                            var act = data[i].sameChildShipToAccounts[j];
                            if (this.roles[act.ParentId] && this.roles[act.ParentId]._children) {
                                var accObj = {
                                    accountName: act.Name,
                                    Id: act.Id,
                                    AccountURL: '/' + act.Id,
                                    currentAccount: false,
                                    Account_Type_Text_Only__c: act.Type_Icon__c ? act.Type_Icon__c : '',
                                    AccountNumber: act.AccountNumber_R1__c ? act.AccountNumber_R1__c : '',
                                    OwnerName_R1__c: act.OwnerName_R1__c ? act.OwnerName_R1__c : '',
                                    LineOfBusiness_R1__c: act.LineOfBusiness_R1__c ? act.LineOfBusiness_R1__c : '',
                                    BillingCity: act.BillingCity ? act.BillingCity : '',
                                    BillingState: act.BillingState ? act.BillingState : '',
                                    BillingCountry: act.BillingCountry ? act.BillingCountry : '',
                                    duplicateShipTo: j,
                                    Address: (act.BillingCity ? act.BillingCity + ' | ' : '') + (act.BillingState ? act.BillingState + ' | ' : '') + (act.BillingCountry ? act.BillingCountry : ''),

                                };
                                if (data[i].childShipToAccounts && data[i].childShipToAccounts.length > 0) {
                                    accObj.hasChildChildren = true;
                                    accObj.hasChildren = this.expandAll;
                                    accObj._children = [{
                                        accountName: data[i].childShipToAccounts[0].Name,
                                        Id: data[i].childShipToAccounts[0].Id,
                                        AccountURL: '/' + data[i].childShipToAccounts[0].Id,
                                        currentAccount: false,
                                        Account_Type_Text_Only__c: data[i].childShipToAccounts[0].Type_Icon__c ? data[i].childShipToAccounts[0].Type_Icon__c : '',
                                        AccountNumber: data[i].childShipToAccounts[0].AccountNumber_R1__c ? data[i].childShipToAccounts[0].AccountNumber_R1__c : '',
                                        OwnerName_R1__c: data[i].childShipToAccounts[0].OwnerName_R1__c ? data[i].childShipToAccounts[0].OwnerName_R1__c : '',
                                        LineOfBusiness_R1__c: data[i].childShipToAccounts[0].LineOfBusiness_R1__c ? data[i].childShipToAccounts[0].LineOfBusiness_R1__c : '',
                                        BillingCity: data[i].childShipToAccounts[0].BillingCity ? data[i].childShipToAccounts[0].BillingCity : '',
                                        BillingState: data[i].childShipToAccounts[0].BillingState ? data[i].childShipToAccounts[0].BillingState : '',
                                        BillingCountry: data[i].childShipToAccounts[0].BillingCountry ? data[i].childShipToAccounts[0].BillingCountry : '',
                                        Address: (data[i].childShipToAccounts[0].BillingCity ? data[i].childShipToAccounts[0].BillingCity + ' | ' : '') + (data[i].childShipToAccounts[0].BillingState ? data[i].childShipToAccounts[0].BillingState + ' | ' : '') + (data[i].childShipToAccounts[0].BillingCountry ? data[i].childShipToAccounts[0].BillingCountry : ''),
                                    }];
                                }
                                this.roles[act.ParentId]._children.push(accObj);
                                this.roles[act.Id + '-' + j] = accObj;
                            }
                        }
                        delete data[i].childShipToAccounts;
                    }
                }
                for (var i = 0; i < data.length; i++) {
                    if (data[i].childShipToAccounts && this.roles[data[i].act.Id] && this.roles[data[i].act.Id]._children) {
                        for (var j = 0; j < data[i].childShipToAccounts.length; j++) {
                            var act = data[i].childShipToAccounts[j];
                            this.roles[data[i].act.Id].hasChildren = this.expandAll;
                            this.roles[data[i].act.Id].hasChildChildren = this.expandAll;
                            this.roles[data[i].act.Id]._children.push({
                                accountName: act.Name,
                                Id: act.Id,
                                AccountURL: '/' + act.Id,
                                currentAccount: this.recordId == act.Id ? true : false,
                                Account_Type_Text_Only__c: act.Type_Icon__c ? act.Type_Icon__c : '',
                                AccountNumber: act.AccountNumber_R1__c ? act.AccountNumber_R1__c : '',
                                OwnerName_R1__c: act.OwnerName_R1__c ? act.OwnerName_R1__c : '',
                                LineOfBusiness_R1__c: act.LineOfBusiness_R1__c ? act.LineOfBusiness_R1__c : '',
                                BillingCity: act.BillingCity ? act.BillingCity : '',
                                BillingState: act.BillingState ? act.BillingState : '',
                                BillingCountry: act.BillingCountry ? act.BillingCountry : '',
                                Address: (act.BillingCity ? act.BillingCity + ' | ' : '') + (act.BillingState ? act.BillingState + ' | ' : '') + (act.BillingCountry ? act.BillingCountry : ''),
                            });
                        }
                    }
                }
                //console.log('***after adding childrens :'+JSON.stringify(this.roles));
                for (var i = 0; i < data.length; i++) {
                    if (this.roles[data[i].act.Id]._children && this.roles[data[i].act.Id]._children.length == 0) {
                        delete this.roles[data[i].act.Id]._children;
                    }

                    if (data[i].act.ParentId) { }
                    else {
                        if (data[i].parentId == data[i].act.Id) {
                            if (this.roles[data[i].act.Id]._children && this.roles[data[i].act.Id]._children.length == 0) {
                                this.roles[data[i].act.Id].parenHasChildren = false;
                            }
                            else {
                                this.roles[data[i].act.Id].parenHasChildren = true;
                                this.roles[data[i].act.Id].hasChildren = this.expandAll;
                            }
                            finaldata.push(this.roles[data[i].act.Id]);
                        }
                    }
                }
                this.gridData = finaldata;
                this.currentExpandedRows = expandedRowInfo;
                if (this.expandAll) {
                    this.chevronDownClass = 'slds-show';
                    this.chevronRightClass = 'slds-hide';
                }
                else {
                    this.chevronDownClass = 'slds-hide';
                    this.chevronRightClass = 'slds-show';
                }
                this.isLoading = false;
            }).catch((err) => {
                console.error("error loading accounts", err);
                this.isLoading = false;
            });

    }

    handleExpandAll = (event) => {
        this.isLoading = true;
        this.expandAll = true;
        this.getAccounts();
    }

    handleCollapseAll = (event) => {
        this.isLoading = true;
        this.expandAll = false;
        this.getAccounts();
    }

    openChild = (event) => {
        var accId = event.currentTarget.dataset.id;
        var finaldata = [];
        this.roles[accId].hasChildren = true;
        for (var i = 0; i < this.allData.length; i++) {
            if (this.allData[i].act.ParentId) {
                if (!this.roles[this.allData[i].act.Id]._children || this.roles[this.allData[i].act.Id]._children.length == 0) {
                    this.roles[this.allData[i].act.Id].hasChildChildren = false;
                }
                else {
                    this.roles[this.allData[i].act.Id].hasChildChildren = true;
                }
            }
            else {
                if (this.allData[i].parentId == this.allData[i].act.Id) {
                    finaldata.push(this.roles[this.allData[i].act.Id]);
                }
            }
        }
        this.gridData = finaldata;
        this.toggleAction(accId, '');
    }

    closeChild = (event) => {
        var finaldata = [];
        var accId = event.currentTarget.dataset.id;
        this.roles[accId].hasChildren = false;
        for (var i = 0; i < this.allData.length; i++) {
            if (this.allData[i].act.ParentId) { }
            else {
                if (this.allData[i].parentId == this.allData[i].act.Id) {

                    finaldata.push(this.roles[this.allData[i].act.Id]);
                }
            }
        }
        this.gridData = finaldata;
        this.toggleAction(accId, '');
    }

    openSecondChild = (event) => {
        var accId = event.currentTarget.dataset.id;
        var name = event.currentTarget.dataset.name;
        var finaldata = [];
        if (!name) {
            this.roles[accId].hasChildren = true;
        }
        else {
            this.roles[accId + '-' + parseInt(name)].hasChildren = true;
        }
        for (var i = 0; i < this.allData.length; i++) {
            if (this.allData[i].act.ParentId) {
                if (!this.roles[this.allData[i].act.Id]._children || this.roles[this.allData[i].act.Id]._children.length == 0) {
                    this.roles[this.allData[i].act.Id].hasChildChildren = false;
                }
                else {
                    this.roles[this.allData[i].act.Id].hasChildChildren = true;
                }
            }
            else {
                if (this.allData[i].parentId == this.allData[i].act.Id) {

                    finaldata.push(this.roles[this.allData[i].act.Id]);
                }
            }
        }
        this.gridData = finaldata;
        this.toggleAction(accId, name == undefined ? '' : name);
    }

    closeSecondChild = (event) => {
        var finaldata = [];
        var accId = event.currentTarget.dataset.id;
        var name = event.currentTarget.dataset.name;
        if (!name) {
            this.roles[accId].hasChildren = false;
        }
        else {
            this.roles[accId + '-' + parseInt(name)].hasChildren = false;
        }
        for (var i = 0; i < this.allData.length; i++) {
            if (this.allData[i].act.ParentId) { }
            else {
                if (this.allData[i].parentId == this.allData[i].act.Id) {

                    finaldata.push(this.roles[this.allData[i].act.Id]);
                }
            }
        }
        this.gridData = finaldata;
        this.toggleAction(accId, name == undefined ? '' : name);
    }

    toggleAction = (accId, name) => {
        const chevronIcons = (name == '' ? this.template.querySelectorAll('[data-id="' + accId + '"]') : this.template.querySelectorAll('[data-id="' + accId + '"][data-name="' + name + '"]'));
        chevronIcons.forEach(icon => {
            icon.classList.toggle('slds-show');
            icon.classList.toggle('slds-hide');
        });
    }

}