public with sharing class ETC_GetAccountsWs extends ETC_Callout {
    public static final String ENDPOINT_NAME = 'getAccounts';
    
    public ETC_GetAccountsWs() {
        super(ENDPOINT_NAME);
        this.claseApex = ETC_GetAccountsWs.class.getName();
    }

    @TestVisible
    public String callService(String queries) {
        String token = ETC_wsLogin.getToken();
        
        Callout callout = createCallout(ENDPOINT_NAME, queries);
        callout.request.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse rawAccounts = sendCallout(callout);

        if (rawAccounts.getStatusCode() == 200 || Test.isRunningTest()) {
            String serviceBody = Test.isRunningTest() ? this.mdt.raw_response__c : rawAccounts.getBody();
            System.debug(serviceBody);
            return serviceBody;
        }

        return null;
    }
    

    public static ETC_ResponseGetAccountsModel getAccounts (Integer page) {
        ETC_GetAccountsWs ws = new ETC_GetAccountsWs();
        String rawResponse = ws.callService('?page=' + page + '&limit=500');
        return ETC_ResponseGetAccountsModel.parse(rawResponse);
    }
}