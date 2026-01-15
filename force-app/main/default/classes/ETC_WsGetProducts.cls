public with sharing class ETC_WsGetProducts extends ETC_Callout {
    public static final String ENDPOINT_NAME = 'getProducts';
    
    public ETC_WsGetProducts() {
        super(ENDPOINT_NAME);
        this.claseApex = ETC_GetAccountsWs.class.getName();
    }

    @TestVisible
    public String callService(String queries) {
        String token = ETC_wsLogin.getToken();
        
        Callout callout = createCallout(ENDPOINT_NAME, queries);
        callout.request.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse rawAccounts = sendCallout(callout);

        system.debug('===========+++++++++++++++++++++++++++++===========');
        system.debug('LOG GET PRODUCT RESPONSE: ' +  rawAccounts.getBody());
        system.debug('===========+++++++++++++++++++++++++++++===========');
        if (rawAccounts.getStatusCode() == 200 || Test.isRunningTest()) {
            String serviceBody = Test.isRunningTest() ? this.mdt.raw_response__c : rawAccounts.getBody();
            return serviceBody;
        }

        return null;
    }

    public static ETC_ModelGetProducts getProducts(Integer pageNumber) {
        ETC_WsGetProducts ws = new ETC_WsGetProducts();
        String response = ws.callService('?page='+ pageNumber +'&limit=1000');
        return ETC_ModelGetProducts.parse(response);
    }
}