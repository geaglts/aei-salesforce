@IsTest
public with sharing class ETC_TestQuotesModule {
    @TestSetup
    static void makeData(){
        update new Pricebook2(Id = Test.getStandardPricebookId());

        List<String> clientsToCreate = new List<String> {'test', '289'};
        Account[] accounts = new List<Account>();

        for (String clientToCreate : clientsToCreate) {
            Account newAccount = new Account();
            newAccount.Name = 'etc' + clientToCreate;
            newAccount.Cliente__c = clientToCreate;
            accounts.add(newAccount);
        }

        insert accounts;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'opp test';
        newOpportunity.CloseDate = Date.today();
        newOpportunity.StageName = 'Proposal';
        newOpportunity.N_mero_de_cotizaci_n__c = 'test';
        newOpportunity.AccountId = accounts[0].Id;
        insert newOpportunity;

        Opportunity newOpportunityWithoutOpportunity = new Opportunity();
        newOpportunityWithoutOpportunity.Name = 'opp test';
        newOpportunityWithoutOpportunity.CloseDate = Date.today();
        newOpportunityWithoutOpportunity.StageName = 'Proposal';
        newOpportunityWithoutOpportunity.N_mero_de_cotizaci_n__c = 'CUN12296';
        newOpportunityWithoutOpportunity.AccountId = accounts[0].Id;
        insert newOpportunityWithoutOpportunity;

        Quote newQuote = new Quote();
        newQuote.Name = 'quote test';
        newQuote.OpportunityId = newOpportunity.Id;
        newQuote.Pricebook2Id = Test.getStandardPricebookId();
        newQuote.N_mero_de_cotizaci_n__c = 'test';
        insert newQuote;

        List<String> productsToCreate = new List<String>{'IL-CLI0-0404', 'EL-LEO0-GEN'};
        for (String productToCreate : productsToCreate) {
            Product2 newProduct = new Product2();
            newProduct.Name = productToCreate;
            newProduct.ProductCode = productToCreate;
            newProduct.External_Id__c = productToCreate;
            newProduct.IsActive = true;
            insert newProduct;
        }

        Sucursal__c newPoint = new Sucursal__c();
        newPoint.Name = 'test';
        newPoint.External_Id__c = '0';
        insert newPoint;
    }
    
    @IsTest
    static void quoteSchedule() {
        String cron = ETC_Utility.getCRONString('');
        Test.startTest();
        ETC_ScheduleGetQuote.start();
        ETC_ScheduleGetQuote scheduleProcess = new ETC_ScheduleGetQuote();
        System.schedule('TEST QUOTES SCHEDULE PROCESS', cron, scheduleProcess);
        Test.stopTest();
    }

    @IsTest
    static void syncQuoteByOppInvocableMethod(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, N_mero_de_cotizaci_n__c FROM Opportunity WHERE N_mero_de_cotizaci_n__c  = 'CUN12296'];
        Test.startTest();
        ETC_GetQuoteWs.Requests input = new ETC_GetQuoteWs.Requests();
        input.accountId = acc.Id;
        input.oppId = opp.Id;
        input.quoteCode = opp.N_mero_de_cotizaci_n__c;
        ETC_GetQuoteWs.syncQuoteFromWs(new List<ETC_GetQuoteWs.Requests> { input });
        ETC_GetQuoteWs.syncQuoteFromWs(null);
        Test.stopTest();
    }

    // Sync Quote Controller Test
    @IsTest
    static void getAccount() {        
        Test.startTest();
        ETC_SyncQuoteController.getAccount('test');
        ETC_SyncQuoteController.getAccount('test_fail');
        Test.stopTest();
    }

    @IsTest
    static void getOpportunity() {        
        Test.startTest();
        ETC_SyncQuoteController.getOpportunity(null);
        ETC_SyncQuoteController.getOpportunity('test');
        ETC_SyncQuoteController.getOpportunity('test_fail');
        Test.stopTest();
    }
    
    @IsTest
    static void getQuote() {        
        Test.startTest();
        ETC_SyncQuoteController.findQuoteByExternalId('test');
        ETC_SyncQuoteController.findQuoteByExternalId('test_fail');
        Test.stopTest();
    }

    @IsTest
    static void generateRecordLink(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        ETC_SyncQuoteController.generateRecordLink(null);
        ETC_SyncQuoteController.generateRecordLink(acc.Id);
        Test.stopTest();
    }

    @IsTest
    static void saveQuoteRecord() {
        Test.startTest();
        ETC_SyncQuoteController.saveQuoteRecord(JSON.serialize(ETC_GetQuoteWs.getQuote('test')));
        Test.stopTest();
    }
}