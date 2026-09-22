import { LightningElement, track } from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityController.getOpportunities';
import getStageOptions from '@salesforce/apex/OpportunityController.getStageOptions';

const COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'recordUrl', type: 'url', sortable: true, fieldNameForSort: 'Name',
      typeAttributes: { label: { fieldName: 'name' }, target: '_self' } },
    { label: 'Account', fieldName: 'accountName', type: 'text', sortable: true, fieldNameForSort: 'Account.Name' },
    { label: 'Stage', fieldName: 'stageName', type: 'text', sortable: true, fieldNameForSort: 'StageName' },
    { label: 'Amount', fieldName: 'amount', type: 'currency', sortable: true, fieldNameForSort: 'Amount',
      typeAttributes: { currencyDisplayAs: 'symbol' } },
    { label: 'Close Date', fieldName: 'closeDate', type: 'date-local', sortable: true, fieldNameForSort: 'CloseDate' }
];

const SEARCH_DELAY = 350;

export default class OpportunityList extends LightningElement {
    columns = COLUMNS;
    @track opportunities = [];
    stageOptions = [{ label: 'All Stages', value: '' }];
    searchTerm = '';
    selectedStage = '';
    sortedBy = 'closeDate';
    sortedDirection = 'asc';
    pageNumber = 1;
    pageSize = 10;
    totalRecords = 0;
    totalPages = 1;
    isLoading = false;
    errorMessage;

    pageSizeOptions = [
        { label: '10', value: '10' },
        { label: '25', value: '25' },
        { label: '50', value: '50' }
    ];

    connectedCallback() {
        this.loadStages();
        this.loadOpportunities();
    }

    disconnectedCallback() {
        clearTimeout(this.searchTimeout);
    }

    async loadStages() {
        try {
            const stages = await getStageOptions();
            this.stageOptions = [
                { label: 'All Stages', value: '' },
                ...stages.map((stage) => ({ label: stage, value: stage }))
            ];
        } catch (error) {
            this.errorMessage = this.reduceError(error);
        }
    }

    async loadOpportunities() {
        this.isLoading = true;
        try {
            const page = await getOpportunities({
                searchTerm: this.searchTerm,
                stage: this.selectedStage,
                pageNumber: this.pageNumber,
                pageSize: this.pageSize,
                sortBy: this.sortFieldApiName,
                sortDirection: this.sortedDirection
            });
            this.opportunities = page.records.map((record) => ({
                id: record.Id,
                name: record.Name,
                recordUrl: `/lightning/r/Opportunity/${record.Id}/view`,
                accountName: record.Account ? record.Account.Name : '',
                stageName: record.StageName,
                amount: record.Amount,
                closeDate: record.CloseDate
            }));
            this.totalRecords = page.totalRecords;
            this.totalPages = page.totalPages;
            this.pageNumber = page.pageNumber;
            this.errorMessage = undefined;
        } catch (error) {
            this.opportunities = [];
            this.totalRecords = 0;
            this.totalPages = 1;
            this.errorMessage = this.reduceError(error);
        } finally {
            this.isLoading = false;
        }
    }

    get sortFieldApiName() {
        const column = COLUMNS.find((item) => item.fieldName === this.sortedBy);
        return column ? column.fieldNameForSort : 'CloseDate';
    }

    handleSearch(event) {
        const value = event.target.value;
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.searchTerm = value;
            this.pageNumber = 1;
            this.loadOpportunities();
        }, SEARCH_DELAY);
    }

    handleStageChange(event) {
        this.selectedStage = event.detail.value;
        this.pageNumber = 1;
        this.loadOpportunities();
    }

    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.pageNumber = 1;
        this.loadOpportunities();
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.pageNumber = 1;
        this.loadOpportunities();
    }

    handlePrevious() {
        if (!this.isFirstPage) {
            this.pageNumber -= 1;
            this.loadOpportunities();
        }
    }

    handleNext() {
        if (!this.isLastPage) {
            this.pageNumber += 1;
            this.loadOpportunities();
        }
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    get hasRecords() {
        return this.opportunities.length > 0;
    }

    get pageLabel() {
        return `Page ${this.pageNumber} of ${this.totalPages} • ${this.totalRecords} opportunities`;
    }

    reduceError(error) {
        return error && error.body && error.body.message
            ? error.body.message
            : 'Opportunities could not be loaded.';
    }
}
