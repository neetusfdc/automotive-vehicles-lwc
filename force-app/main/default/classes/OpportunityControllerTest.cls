@IsTest
private class OpportunityControllerTest {
    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Acme Motors');
        insert account;

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 15; i++) {
            opportunities.add(
                new Opportunity(
                    Name = 'Fleet Deal ' + String.valueOf(i).leftPad(2, '0'),
                    AccountId = account.Id,
                    StageName = Math.mod(i, 2) == 0 ? 'Prospecting' : 'Closed Won',
                    Amount = 1000 * (i + 1),
                    CloseDate = Date.today().addDays(i)
                )
            );
        }
        opportunities.add(
            new Opportunity(
                Name = 'Service Contract',
                AccountId = account.Id,
                StageName = 'Prospecting',
                Amount = 500,
                CloseDate = Date.today().addDays(60)
            )
        );
        insert opportunities;
    }

    @IsTest
    static void returnsFirstPageWithTotals() {
        Test.startTest();
        OpportunityController.OpportunityPage page = OpportunityController.getOpportunities(
            null,
            null,
            1,
            10,
            'CloseDate',
            'ASC'
        );
        Test.stopTest();

        System.assertEquals(16, page.totalRecords);
        System.assertEquals(2, page.totalPages);
        System.assertEquals(10, page.records.size());
        System.assertEquals('Fleet Deal 00', page.records[0].Name);
        System.assertEquals('Acme Motors', page.records[0].Account.Name);
    }

    @IsTest
    static void filtersBySearchTermAndStage() {
        Test.startTest();
        OpportunityController.OpportunityPage searched = OpportunityController.getOpportunities(
            'Service',
            null,
            1,
            10,
            'Name',
            'ASC'
        );
        OpportunityController.OpportunityPage filtered = OpportunityController.getOpportunities(
            null,
            'Closed Won',
            1,
            50,
            'Name',
            'ASC'
        );
        Test.stopTest();

        System.assertEquals(1, searched.totalRecords);
        System.assertEquals('Service Contract', searched.records[0].Name);
        System.assertEquals(7, filtered.totalRecords);
        for (Opportunity opportunity : filtered.records) {
            System.assertEquals('Closed Won', opportunity.StageName);
        }
    }

    @IsTest
    static void sortsDescendingAndClampsPageNumber() {
        Test.startTest();
        OpportunityController.OpportunityPage page = OpportunityController.getOpportunities(
            'Fleet',
            null,
            99,
            10,
            'Amount',
            'DESC'
        );
        Test.stopTest();

        System.assertEquals(2, page.pageNumber);
        System.assertEquals(5, page.records.size());
        System.assertEquals(5000, page.records[0].Amount);
    }

    @IsTest
    static void fallsBackForInvalidSortAndPageSize() {
        Test.startTest();
        OpportunityController.OpportunityPage page = OpportunityController.getOpportunities(
            null,
            null,
            0,
            0,
            'Name__c; DROP',
            'sideways'
        );
        Test.stopTest();

        System.assertEquals(1, page.pageNumber);
        System.assertEquals(10, page.pageSize);
        System.assertEquals(Date.today(), page.records[0].CloseDate);
    }

    @IsTest
    static void returnsActiveStageOptions() {
        Test.startTest();
        List<String> stages = OpportunityController.getStageOptions();
        Test.stopTest();

        System.assert(!stages.isEmpty());
        System.assert(stages.contains('Prospecting'));
    }
}
