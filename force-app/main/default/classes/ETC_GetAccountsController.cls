public virtual with sharing class ETC_GetAccountsController {
	public Account[] accountList;
	public Contact[] contactList;
	public Map<String,String> usersByAgentCode;
	public String DEFAULT_OWNER;

	public ETC_GetAccountsController() {
		accountList = new List<Account>();
		contactList = new List<Contact>();
		usersByAgentCode = new Map<String,String>();
	}

	public void setUsersByAgent(Map<String,String> users) {
		this.usersByAgentCode = users;
	}

	public void sync(ETC_ResponseGetAccountsModel serviceResponse) {
		buildSObject(serviceResponse.data);
	}

	public void buildSObject(List<ETC_ResponseGetAccountsModel.Data> clients) {
		System.debug('===START_Clients===');
		System.debug(clients);
		System.debug('===END_Clients===');
		for (ETC_ResponseGetAccountsModel.Data client : clients) {
			buildSObjectAccount(client);
		}
	}

	public void buildSObjectAccount(ETC_ResponseGetAccountsModel.Data client) {
		Account newAccount = new Account();
		newAccount.Name = client.Nombre;
		newAccount.Cliente__c = client.Cliente;
        newAccount.BillingStreet = client.Direccion;
        newAccount.N_mero_de_facturaci_n__c = client.DireccionNumero;
        newAccount.Colonia_de_facturaci_n__c = client.Colonia;
        newAccount.Poblacion_de_facturacion__c = client.Poblacion;
		if (String.isNotBlank(client.Pais)) {
			newAccount.BillingCity = client.Delegacion;
			newAccount.BillingState = client.Estado;
			newAccount.BillingCountry = client.Pais;
			newAccount.BillingPostalCode = client.CodigoPostal;
		}
        newAccount.RFC__c = client.RFC;
        newAccount.Email__c = client.eMail1;
        // newAccount.ZonaImpuesto__c = client.ZonaImpuesto;
        newAccount.Condici_n__c = client.Condicion;
        newAccount.ListaPreciosEsp__c = client.ListaPreciosEsp;
        newAccount.Estatus__c = client.Estatus;
        newAccount.Agente__c = client.Agente;

        // user reference
		if (this.usersByAgentCode.containsKey(client.Agente)) {
			newAccount.OwnerId = this.usersByAgentCode.get(client.Agente);
		} else {
			newAccount.OwnerId = this.usersByAgentCode.get(DEFAULT_OWNER);
		}
        
		accountList.add(newAccount);
		buildSObjectContact(client.Cliente, client.contactos);
	}

	public void buildSObjectContact(String accountId, List<ETC_ResponseGetAccountsModel.Contactos> contacts) {
		Account accountRef = new Account(Cliente__c = accountId);
		if (contacts != null) {
			for (ETC_ResponseGetAccountsModel.Contactos contact : contacts) {
				Contact newContact = new Contact();
				if (String.isNotBlank((contact.Nombre))) {
					newContact.LastName = contact.Nombre;
				} else if (String.isNotBlank(contact.eMail)) {
					newContact.LastName = contact.eMail;
				} else {
					newContact.LastName = String.valueOf(contact.ID);
				}
				System.debug('-----------------------------------');
				System.debug(contact.ID);
				System.debug(newContact.LastName);
				System.debug('-----------------------------------');
				newContact.Id_Contacto__c = String.valueOf(contact.ID);
				newContact.Account = accountRef;
				contactList.add(newContact);
			}
		}
	}
}