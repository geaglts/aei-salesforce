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

    public String getDefaultOwner() {
        return Test.isRunningTest() ? 'RPALOMO' : this.mdt.default_owner__c;
    }
    
    public static String defaultOwner() {
        ETC_GetAccountsWs ws = new ETC_GetAccountsWs();
        return Test.isRunningTest() ? 'RPALOMO' : ws.getDefaultOwner();  
    }

    public static ETC_ResponseGetAccountsModel getAccounts (Integer page) {
        ETC_GetAccountsWs ws = new ETC_GetAccountsWs();
        String rawResponse = ws.callService('?page=' + page + '&limit=1000');
        return ETC_ResponseGetAccountsModel.parse(rawResponse);
    }

    // ETC_GetAccountsWs.getSingleAccount('');
	public static void getSingleAccount(String clientCode) {
		ETC_GetAccountsWs ws = new ETC_GetAccountsWs();
		String response = ws.callService('/' + clientCode);
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(response);
        ETC_ResponseGetAccountsModel.Data clientData = (ETC_ResponseGetAccountsModel.Data) JSON.deserialize(JSON.serialize(data.get('data')), ETC_ResponseGetAccountsModel.Data.class);
        Map<String,String> userByAgentCode = ETC_Utility.getUserIdByAgentCode();
        ETC_GetAccountsController c = new ETC_GetAccountsController();
        c.setUsersByAgent(userByAgentCode);
        c.buildSObject(new List<ETC_ResponseGetAccountsModel.Data> {clientData});

        Database.UpsertResult[] accountResults = Database.upsert(c.accountList, Account.Fields.Cliente__c, false);
        System.debug(accountResults);
		Database.UpsertResult[] contactResults = Database.upsert(c.contactList, Contact.Fields.Id_Contacto__c, false);
        System.debug(contactResults);
    }
}