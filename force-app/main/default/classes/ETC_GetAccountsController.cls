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
		// buildSObjectContact(client.codigo, client.personasContacto);
	}

	// public void buildSObjectContact(String accountId, ETC_ResponseGetAccountsModel.PersonasContacto[] contacts) {
	// 	Account accountRef = new Account(C_digo__c = accountId);
	// 	if (contacts != null) {
	// 		for (ETC_ResponseGetAccountsModel.PersonasContacto contact : contacts) {
	// 			Contact newContact = new Contact();
	// 			// System.debug(accountId + '_' + contact.id);
	// 			newContact.External_Id__c = accountId + '_' + contact.id; // external
	// 			newContact.MobilePhone = contact.movil;
	// 			List<String> emails = ETC_Utility.getValidEmails(contact.correo);
	// 			if (emails.size() > 0) {
	// 				newContact.Email = emails[0];
	// 			}
	// 			newContact.LastName = contact.nombre;
	// 			newContact.Title = contact.posicion;
	// 			newContact.Contacto_Principal__c = contact.principal == 'Y';
	// 			newContact.Phone = contact.telefono1;
	// 			newContact.OtherPhone = contact.telefono2;
	// 			newContact.Account = accountRef;
	// 			contactList.add(newContact);
	// 		}
	// 	}
	// }
}
