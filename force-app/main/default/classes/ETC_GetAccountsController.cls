public virtual with sharing class ETC_GetAccountsController {
	public Account[] accountList;
	public Contact[] contactList;

	public ETC_GetAccountsController() {
		accountList = new List<Account>();
		contactList = new List<Contact>();
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
        // newAccount.BillingStreet = client.Direccion;
        // newAccount.N_mero_de_facturaci_n__c = client.DireccionNumero;
        // newAccount.Delegaci_n_de_facturaci_n__c = client.Delegacion;
        // newAccount.Colonia_de_facturaci_n__c = client.Colonia;
        // newAccount.BillingCity = client.Poblacion;
        // newAccount.BillingState = client.Estado;
        // newAccount.BillingCountry = client.Pais;
        // newAccount.BillingPostalCode = client.CodigoPostal;
        // newAccount.RFC__c = client.RFC;
        // newAccount.Condici_n__c = client.Condicion;
        // newAccount.Estatus__c = client.Estatus;
        // newAccount.Email__c = client.eMail1;

        // user reference
        // newAccount.Owner.Agente__c = client.Agente;
        
		accountList.add(newAccount);
		buildSObjectContact(client.Cliente, client.contactos);
	}

	public void buildSObjectContact(String accountId, List<ETC_ResponseGetAccountsModel.Contactos> contacts) {
		Account accountRef = new Account(Cliente__c = accountId);
		if (contacts != null) {
			for (ETC_ResponseGetAccountsModel.Contactos contact : contacts) {
				Contact newContact = new Contact();
				if (contact.Nombre != null && contact.Nombre != '') {
					newContact.LastName = contact.Nombre;
				} else if (contact.eMail != null && contact.eMail != '') {
					newContact.LastName = contact.eMail;
				} else {
					newContact.LastName = String.valueOf(contact.ID);
				}
				newContact.Id_Contacto__c = String.valueOf(contact.ID);
				newContact.Account = accountRef;
				contactList.add(newContact);
			}
		}
	}
}