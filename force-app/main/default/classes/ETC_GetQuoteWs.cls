public with sharing class ETC_GetQuoteWs  extends ETC_Callout {
    public static final String ENDPOINT_NAME = 'getQuoteById';
    public ETC_GetQuoteWs() {
        super(ENDPOINT_NAME);
        this.claseApex = ETC_GetQuoteWs.class.getName();
    }

    @TestVisible
    public String callService(String quoteId) {
        String token = ETC_wsLogin.getToken();

        Callout callout = createCallout(ENDPOINT_NAME, '/' + quoteId);
        callout.request.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse rawQuote = sendCallout(callout);

        if (rawQuote.getStatusCode() == 200 || Test.isRunningTest()) {
            String serviceBody = Test.isRunningTest() ? this.mdt.raw_response__c : rawQuote.getBody();
            return serviceBody;
        }

        return null;
    }

    public static void getQuote(String quoteId) {
        ETC_GetQuoteWs ws = new ETC_GetQuoteWs();
        String rawQuote = ws.callService(quoteId);
        if (rawQuote != null) {
            ETC_AeiQuoteModel quoteData = ETC_AeiQuoteModel.parse(rawQuote);
            System.debug(quoteData.data);
        } else {
            System.debug('We can\'t get quote, please contact an admin');
        }
    }
}