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

    @AuraEnabled(cacheable=false)
    public static ETC_AeiQuoteModel getQuote(String quoteId) {
        ETC_GetQuoteWs ws = new ETC_GetQuoteWs();
        String rawQuote = ws.callService(quoteId);
        if (rawQuote != null) {
            try {
                ETC_AeiQuoteModel quoteData = ETC_AeiQuoteModel.parse(rawQuote);
                return quoteData;
            } catch (Exception e) {
                System.debug(e);
                return null;
            }
        } else {
            return null;
        }
    }

    /* 
        TODO Agregar un metodo invocable para poder consultar una cotización por su external Id y guardar el registro
        Obtenermos el id de la oportunidad que sera la que se estara vinculando a la cotización
        Obtenemos el extenalId (código de la cotización) para consultar el metodo getQuote que llama el ws
            En la respuesta del servicio guardamos en sfAccountId el cliente
            En la respuesta del servicio guardamos en sfOppId guardamos la oportunidad
        Mandamos a llamar el metodo saveQuoteRecord de ETC_SyncQuoteController donde enviamos el String de la quote
    */
    @InvocableMethod(label='Sync quote from ws' description='Sync Quote By Opp Id And Quote Code')
    public static List<Results> syncQuoteFromWs(List<Requests> requestList) {
        List<Results> results = new List<Results>();
        try {
            // get opportunity record
            ETC_AeiQuoteModel wsQuote = ETC_GetQuoteWs.getQuote(requestList[0].quoteCode);
            // add additional quote params with opp data
            wsQuote.data.sfAccountId = requestList[0].accountId;
            wsQuote.data.sfOppId = requestList[0].oppId;
            // try to sync and create the quoteRecord
            Map<String, String> syncQuoteResult = ETC_SyncQuoteController.saveQuoteRecord(JSON.serialize(wsQuote));         

            // System.debug('Pedido Creado con Exito?');
            // System.debug(syncQuoteResult);

            String finalResponse = 'Resultado de la sincronizacion:\n';
            Boolean errorResult = false;
            for (String key : syncQuoteResult.keySet()) {
                if (key == 'error') {
                    errorResult = true;
                    finalResponse += key.toUpperCase() + ': ' + syncQuoteResult.get(key) + '\n';
                }
                // finalResponse += key.toUpperCase() + ': ' + syncQuoteResult.get(key) + '\n';
            }

            if (!errorResult) {
                finalResponse += 'La cotización fue sincronizada correctamente';
            }
            
            Results result = new Results();
            result.result = !errorResult;
            result.message = finalResponse;
            results.add(result);
        } catch (Exception e) {
            System.debug('ETC_GetQuoteWs|syncQuoteFromWs');
            System.debug('Error: ' + e);
            System.debug('ETC_GetQuoteWs|syncQuoteFromWs');
            Results result = new Results();
            result.result = false;
            result.message = 'La cotización no pudo se sincronizada';
            results.add(result);
        }

        return results;
    }

    public class Requests {
        @InvocableVariable(label='Opporunity Id' required=true)
        public String oppId;
        @InvocableVariable(label='Account Id' required=true)
        public String accountId;
        @InvocableVariable(label='Quote External Id' required=true)
        public String quoteCode;
    }

    public class Results {
        @InvocableVariable(label='Operation result' description='Return a boolean (true, false)')
        public Boolean result;
        @InvocableVariable(label='Operation message' description='Return a message for the operation')
        public String message;
    }

}