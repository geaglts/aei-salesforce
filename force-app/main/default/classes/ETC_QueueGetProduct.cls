/*
ETC_QueueGetProduct.queue(1, false);
*/
public with sharing class ETC_QueueGetProduct extends ETC_ControllerGetProduct implements Queueable {
    public List<Product2> queueProductList;
    public Integer nextPage;
    public Boolean isSinglePage;
    
    public ETC_QueueGetProduct(Integer page, Boolean single) {
        this.sync(ETC_WsGetProducts.getProducts(page));
		this.queueProductList = this.productList;		
		this.nextPage = page + 1;
		this.isSinglePage = single;
        System.debug('===PRODUCTOS_EN_COLA===');
		System.debug(this.queueProductList);
		System.debug('Next Page=' + this.nextPage);
		System.debug('===PRODUCTOS_EN_COLA===');
    }

    public void execute(QueueableContext context) {
        System.debug('Pagina=' + String.valueOf(this.nextPage - 1));
		if (!this.queueProductList.isEmpty()) {
			Database.UpsertResult[] productResults = Database.upsert(this.queueProductList, Product2.Fields.External_Id__c, false);

			List<Integer> upProductResults = ETC_Utility.showQueueResult(productResults, 'Productos', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upProductResults[0] + ' Registros exitosos. Productos');
			System.debug('Se procesaron: ' + upProductResults[1] + ' Registros con errores. Productos');

			if (!this.isSinglePage) {
				ETC_QueueGetProduct.queue(this.nextPage, false);
			}
		}
    }

    @future(callout=true)
	public static void queue(Integer page, Boolean single) {
		execute(page, single);
	}

	public static void execute(Integer page, Boolean single) {
		ETC_QueueGetProduct q = new ETC_QueueGetProduct(page, single);
		System.enqueueJob(q);
	}
}