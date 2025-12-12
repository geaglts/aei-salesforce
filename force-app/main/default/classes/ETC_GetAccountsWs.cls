public with sharing class ETC_GetAccountsWs extends ETC_Callout {
    public static final String ENDPOINT_NAME = 'login';
    
    public ETC_GetAccountsWs() {
        super(ENDPOINT_NAME);
        this.claseApex = ETC_GetAccountsWs.class.getName();
    }

    public class LoginResponse {
        public String token;
    }
    
    @TestVisible
    public String callService(Boolean refresh) {
        Callout callout = createCallout(ENDPOINT_NAME, '');

        if (!refresh) {
            return this.env.token__c;
        }
        
        String requestBody = JSON.serialize(new Map<String, Object> {
            'username' => this.env.username__c,
            'password' => this.env.password__c
        });

        callout.request.setBody(requestBody);

        HttpResponse loginResponse = sendCallout(callout);
        if (loginResponse.getStatusCode() == 200 || Test.isRunningTest()) {
            String serviceBody = Test.isRunningTest() ? this.mdt.raw_response__c : loginResponse.getBody();
            System.debug(serviceBody);
            return serviceBody;
        }
        
        return null;
    }

    @future(callout=true)
    public static void refreshToken() {
        ETC_GetAccountsWs ws = new ETC_GetAccountsWs();
        String rawResponse = ws.callService(false);
        if (rawResponse != null) {
            LoginResponse loginData = (LoginResponse) JSON.deserialize(rawResponse, LoginResponse.class);
            ETC_Utility.updateEnvironmentMetadata(ws.mdt.env__c, 'token__c', loginData.token);
        } else {
            System.debug('We can\'t get token, please contact an admin');
        }
    }

    public static String getToken() {
        ETC_GetAccountsWs ws = new ETC_GetAccountsWs();
        String rawResponse = ws.callService(true);
        return rawResponse;
    }
}