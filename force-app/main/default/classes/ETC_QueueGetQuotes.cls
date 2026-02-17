/*
Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = TRUE];
// params(page, isSingle, standardPricebookId);
ETC_QueueGetQuotes.queue(1, true, standardPricebook.Id);
// filter: QueueableHandler
// filter: FutureHandler
*/
public with sharing class ETC_QueueGetQuotes extends ETC_ControllerGetQuotes implements Queueable {
    public List<Opportunity> queueQuoteOpportunity;
    public List<Quote> queueQuotes;
    public List<QuoteLineItem> queueQuoteLineItems;
    public List<Order> queueOrders;
    public List<OrderItem> queueOrderItems;
    public Integer nextPage;
    public Boolean isSinglePage;
    
    public ETC_QueueGetQuotes(Integer page, Boolean single, String standardPricebookId) {
        this.setGlobalParams(standardPricebookId);
        this.sync(ETC_GetQuoteWs.getByPage(page));
        this.queueQuoteOpportunity = this.quoteOpportunity;
        this.queueQuotes = this.quotes;
        this.queueQuoteLineItems = this.quoteLineItems;
        this.queueOrders = this.orders;
        this.queueOrderItems = this.orderItems;

		this.nextPage = page + 1;
		this.isSinglePage = single;
        System.debug('===COTIZACIONES_EN_COLA===');
		System.debug(this.queueQuotes);
		System.debug('Next Page=' + this.nextPage);
		System.debug('===COTIZACIONES_EN_COLA===');
    }

    public void execute(QueueableContext context) {
        System.debug('Pagina=' + String.valueOf(this.nextPage - 1));
		if (!this.queueQuotes.isEmpty()) {
			Database.UpsertResult[] opportunityResults = Database.upsert(this.quoteOpportunity, Opportunity.Fields.N_mero_de_cotizaci_n__c, false);
			Database.UpsertResult[] quoteResults = Database.upsert(this.queueQuotes, Quote.Fields.N_mero_de_cotizaci_n__c, false);
			Database.UpsertResult[] quoteLineResults = Database.upsert(this.quoteLineItems, QuoteLineItem.Fields.External_Id__c, false);
			Database.UpsertResult[] orderResults = Database.upsert(this.queueOrders, Order.Fields.Id_de_Movimiento__c, false);
			Database.UpsertResult[] orderItemResults = Database.upsert(this.queueOrderItems, OrderItem.Fields.External_Id__c, false);

			List<Integer> upOpportunityResults = ETC_Utility.showQueueResult(opportunityResults, 'Oportunidades', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upOpportunityResults[0] + ' Registros exitosos. Oportunidades');
			System.debug('Se procesaron: ' + upOpportunityResults[1] + ' Registros con errores. Oportunidades');
            
			List<Integer> upQuoteResults = ETC_Utility.showQueueResult(quoteResults, 'Cotizaciones', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upQuoteResults[0] + ' Registros exitosos. Cotizaciones');
			System.debug('Se procesaron: ' + upQuoteResults[1] + ' Registros con errores. Cotizaciones');

			List<Integer> upQuoteLineResults = ETC_Utility.showQueueResult(quoteLineResults, 'Lineas de cotización', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upQuoteLineResults[0] + ' Registros exitosos. Lineas de cotización');
			System.debug('Se procesaron: ' + upQuoteLineResults[1] + ' Registros con errores. Lineas de cotización');

			List<Integer> upOrderResults = ETC_Utility.showQueueResult(orderResults, 'Pedidos', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upOrderResults[0] + ' Registros exitosos. Pedidos');
			System.debug('Se procesaron: ' + upOrderResults[1] + ' Registros con errores. Pedidos');

			List<Integer> upOrderItemResults = ETC_Utility.showQueueResult(orderItemResults, 'Productos de pedido', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upOrderItemResults[0] + ' Registros exitosos. Productos de pedido');
			System.debug('Se procesaron: ' + upOrderItemResults[1] + ' Registros con errores. Productos de pedido');

			if (!this.isSinglePage) {
				ETC_QueueGetQuotes.queue(this.nextPage, false, this.standardPricebookId);
			}
		}
    }

    @future(callout=true)
	public static void queue(Integer page, Boolean single, String standardPricebookId) {
		execute(page, single, standardPricebookId);
	}

	public static void execute(Integer page, Boolean single, String standardPricebookId) {
		ETC_QueueGetQuotes q = new ETC_QueueGetQuotes(page, single, standardPricebookId);
		System.enqueueJob(q);
	}
}