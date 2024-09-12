import { LightningElement, api } from 'lwc';
export default class CallReportFlowFooter extends LightningElement {
    @api callReportId;

    handleFinish = () => {
        window.open('/' + this.callReportId, '_self');
    }
}