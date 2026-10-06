import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getRecommendations from '@salesforce/apex/DispatcherController.getRecommendations';
import assignTechnician from '@salesforce/apex/DispatcherController.assignTechnician';

function reduceError(error) {
    return (error && error.body && error.body.message) || (error && error.message) || 'Unknown error';
}

export default class DispatcherAssign extends LightningElement {
    _recordId;
    rows;
    error;
    isLoading = false;

    columns = [
        { label: 'Technician', fieldName: 'technicianName' },
        { label: 'Score', fieldName: 'score', type: 'number', typeAttributes: { maximumFractionDigits: 1 } },
        { label: 'Distance (km)', fieldName: 'distanceKm', type: 'number', typeAttributes: { maximumFractionDigits: 1 } },
        { label: 'Open jobs', fieldName: 'workload', type: 'number' },
        { type: 'button', typeAttributes: { label: 'Assign', name: 'assign', variant: 'brand' } }
    ];

    // Quick actions provide recordId after construction, so load when it arrives.
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.load();
        }
    }

    get hasRows() {
        return this.rows && this.rows.length > 0;
    }
    get showEmpty() {
        return this.rows && this.rows.length === 0 && !this.error;
    }

    async load() {
        this.isLoading = true;
        this.error = undefined;
        try {
            this.rows = await getRecommendations({ caseId: this._recordId });
        } catch (e) {
            this.error = reduceError(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleRowAction(event) {
        this.isLoading = true;
        try {
            await assignTechnician({ caseId: this._recordId, technicianId: event.detail.row.technicianId });
            this.dispatchEvent(new ShowToastEvent({ title: 'Assigned', message: `${event.detail.row.technicianName} was assigned.`, variant: 'success' }));
            await notifyRecordUpdateAvailable([{ recordId: this._recordId }]);
            this.handleClose();
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Could not assign', message: reduceError(e), variant: 'error' }));
        } finally {
            this.isLoading = false;
        }
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
