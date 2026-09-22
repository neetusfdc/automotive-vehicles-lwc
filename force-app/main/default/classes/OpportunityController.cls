public with sharing class OpportunityController {
    private static final Integer MAX_PAGE_SIZE = 100;
    private static final Set<String> SORTABLE_FIELDS = new Set<String>{
        'Name',
        'Account.Name',
        'StageName',
        'Amount',
        'CloseDate'
    };

    public class OpportunityPage {
        @AuraEnabled
        public List<Opportunity> records { get; set; }
        @AuraEnabled
        public Integer totalRecords { get; set; }
        @AuraEnabled
        public Integer pageNumber { get; set; }
        @AuraEnabled
        public Integer pageSize { get; set; }
        @AuraEnabled
        public Integer totalPages { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getStageOptions() {
        List<String> stages = new List<String>();
        for (Schema.PicklistEntry entry : Opportunity.StageName.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                stages.add(entry.getValue());
            }
        }
        return stages;
    }

    @AuraEnabled(cacheable=true)
    public static OpportunityPage getOpportunities(
        String searchTerm,
        String stage,
        Integer pageNumber,
        Integer pageSize,
        String sortBy,
        String sortDirection
    ) {
        Integer safePageSize = pageSize == null || pageSize <= 0 ? 10 : Math.min(pageSize, MAX_PAGE_SIZE);
        Integer safePageNumber = pageNumber == null || pageNumber <= 0 ? 1 : pageNumber;
        String orderField = SORTABLE_FIELDS.contains(sortBy) ? sortBy : 'CloseDate';
        String orderDirection = 'DESC'.equalsIgnoreCase(sortDirection) ? 'DESC' : 'ASC';

        String nameFilter = '%' + String.escapeSingleQuotes(String.isBlank(searchTerm) ? '' : searchTerm.trim()) + '%';
        Boolean filterByStage = String.isNotBlank(stage);
        String stageFilter = stage;

        Integer totalRecords = filterByStage
            ? [SELECT COUNT() FROM Opportunity WHERE Name LIKE :nameFilter AND StageName = :stageFilter]
            : [SELECT COUNT() FROM Opportunity WHERE Name LIKE :nameFilter];

        Integer totalPages = totalRecords == 0 ? 1 : (Integer) Math.ceil((Decimal) totalRecords / safePageSize);
        if (safePageNumber > totalPages) {
            safePageNumber = totalPages;
        }
        Integer offset = (safePageNumber - 1) * safePageSize;

        String query =
            'SELECT Id, Name, StageName, Amount, CloseDate, AccountId, Account.Name ' +
            'FROM Opportunity ' +
            'WHERE Name LIKE :nameFilter ' +
            (filterByStage ? 'AND StageName = :stageFilter ' : '') +
            'ORDER BY ' + orderField + ' ' + orderDirection + ' NULLS LAST, Id ' +
            'LIMIT :safePageSize OFFSET :offset';

        OpportunityPage page = new OpportunityPage();
        page.records = Database.query(query);
        page.totalRecords = totalRecords;
        page.pageNumber = safePageNumber;
        page.pageSize = safePageSize;
        page.totalPages = totalPages;
        return page;
    }
}
