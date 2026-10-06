import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMyJobs from '@salesforce/apex/WorkOrderController.getMyJobs';
import updateStatus from '@salesforce/apex/WorkOrderController.updateStatus';

// The next action a technician can take from each status (mirrors the Apex state machine).
const NEXT = {
    ASSIGNED: { status: 'ACCEPTED', label: 'Accept Job' },
    ACCEPTED: { status: 'EN_ROUTE', label: 'Start Travel' },
    EN_ROUTE: { status: 'ON_SITE', label: 'Arrived On Site' },
    ON_SITE: { status: 'IN_PROGRESS', label: 'Start Work' },
    IN_PROGRESS: { status: 'COMPLETED', label: 'Complete Job' }
};

function reduceError(error) {
    return (error && error.body && error.body.message) || (error && error.message) || 'Unknown error';
}

function pad(n) {
    return String(n).padStart(2, '0');
}

export default class TechnicianJobs extends LightningElement {
    rawJobs = [];
    jobs = [];
    error;
    isLoading = true;
    completingId;
    resolution = '';
    timer;
    wiredResult;

    @wire(getMyJobs)
    wiredJobs(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.rawJobs = data;
            this.error = undefined;
            this.buildJobs();
        } else if (error) {
            this.error = reduceError(error);
            this.rawJobs = [];
            this.jobs = [];
        }
        this.isLoading = false;
    }

    connectedCallback() {
        this.timer = setInterval(() => this.buildJobs(), 1000); // live SLA countdown
    }

    disconnectedCallback() {
        clearInterval(this.timer); // avoid leaking the timer when the component is removed
    }

    get noJobs() {
        return !this.isLoading && !this.error && this.jobs.length === 0;
    }

    buildJobs() {
        this.jobs = this.rawJobs.map((wo) => {
            const next = NEXT[wo.Status__c];
            const c = wo.Case__r || {};
            const sla = this.slaInfo(c.SLA_Deadline__c);
            return {
                id: wo.Id,
                name: wo.Name,
                caseNumber: c.CaseNumber,
                subject: c.Subject || wo.Description__c,
                priority: c.Priority,
                priorityClass: c.Priority === 'High' || c.Priority === 'Critical' ? 'slds-theme_error' : '',
                status: wo.Status__c,
                slaText: sla.text,
                slaClass: sla.breached ? 'slds-text-color_error' : 'slds-text-color_default',
                hasAction: !!next,
                nextStatus: next ? next.status : null,
                actionLabel: next ? next.label : '',
                isCompleting: this.completingId === wo.Id
            };
        });
    }

    slaInfo(deadline) {
        if (!deadline) {
            return { text: 'No SLA', breached: false };
        }
        const ms = new Date(deadline).getTime() - Date.now();
        if (ms <= 0) {
            return { text: 'BREACHED', breached: true };
        }
        const s = Math.floor(ms / 1000);
        return { text: `${pad(Math.floor(s / 3600))}:${pad(Math.floor((s % 3600) / 60))}:${pad(s % 60)}`, breached: false };
    }

    handleAction(event) {
        const { id, status } = event.currentTarget.dataset;
        if (status === 'COMPLETED') {
            this.completingId = id; // ask for the resolution first
            this.resolution = '';
            this.buildJobs();
            return;
        }
        this.save(id, status);
    }

    handleResolutionChange(event) {
        this.resolution = event.target.value;
    }

    handleCancelComplete() {
        this.completingId = undefined;
        this.buildJobs();
    }

    handleConfirmComplete(event) {
        if (!this.resolution || !this.resolution.trim()) {
            this.toast('Resolution required', 'Please describe what you did.', 'warning');
            return;
        }
        this.save(event.currentTarget.dataset.id, 'COMPLETED', this.resolution);
    }

    async save(workOrderId, newStatus, resolution) {
        this.isLoading = true;
        try {
            await updateStatus({ workOrderId, newStatus, resolution });
            this.toast('Updated', `Job moved to ${newStatus}`, 'success');
            this.completingId = undefined;
            await refreshApex(this.wiredResult);
        } catch (e) {
            this.toast('Could not update job', reduceError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
