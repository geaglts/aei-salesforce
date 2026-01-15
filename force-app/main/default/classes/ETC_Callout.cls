public virtual with sharing class ETC_Callout {
	public endpoint__mdt mdt;
	public environment__mdt env;
	public String claseApex;

	public class Callout {
		public Http http;
		public HttpRequest request;
		public HttpResponse response;
		public Callout(Http http, HttpRequest request, HttpResponse response) {
			this.http = http;
			this.request = request;
			this.response = response;
		}
	}

	public ETC_Callout() {
	}

	public ETC_Callout(String metadataName) {
		this.mdt = ETC_Utility.getEndpoint(metadataName);
		this.env = ETC_Utility.getEnv(mdt.env__c);
	}

	public virtual Callout createCallout(String metadataName, String queries) {
		endpoint__mdt mdt = this.mdt != null ? this.mdt : ETC_Utility.getEndpoint(metadataName);
		environment__mdt env =  this.env != null ? this.env : ETC_Utility.getEnv(this.mdt.env__c);

		this.mdt = mdt;
		this.env = env;

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();

		String endpoint = env.host__c + mdt.endpoint__c;
		if (queries != null) {
			endpoint += queries;
		}
		
		request.setEndpoint(endpoint);
		request.setMethod(mdt.method__c);
		request.setHeader('Accept-Encoding', 'gzip, deflate, br');
		request.setHeader('Accept', '*/*');
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('User-Agent', 'Salesforce');
		request.setHeader('Connection', 'Keep-Alive');
		// request.setCompressed(true);
		request.setTimeout(120000);
		return new Callout(http, request, response);
	}

	public virtual HttpResponse sendCallout(Callout callout) {
		callout.response = new HttpResponse();
		if (!Test.isRunningTest()) {
			callout.response = callout.http.send(callout.request);
		}
		return callout.response;
	}
}