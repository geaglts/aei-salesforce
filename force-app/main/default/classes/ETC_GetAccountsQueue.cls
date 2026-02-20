/*
ETC_GetAccountsQueue.queue(1, false, null);
*/
public with sharing class ETC_GetAccountsQueue extends ETC_GetAccountsController implements Queueable {
	public Account[] queueAccountList;
	public Contact[] queueContactList;
	public Integer nextPage;
	public Boolean isSinglePage;
	public Map<String,String> usersByAgentCode;

	public ETC_GetAccountsQueue(Integer page, Boolean single, Map<String,String> users) {
		this.DEFAULT_OWNER = ETC_GetAccountsWs.defaultOwner();
		if (users == null || users.size() == 0) {
			this.usersByAgentCode = ETC_Utility.getUserIdByAgentCode();
		} else {
			this.usersByAgentCode = users;
		}
		this.setUsersByAgent(this.usersByAgentCode);
		this.sync(ETC_GetAccountsWs.getAccounts(page));
		this.queueAccountList = this.accountList;
		this.queueContactList = this.contactList;
		this.nextPage = page + 1;
		this.isSinglePage = single;
		
		System.debug('===START_CUENTAS_EN_COLA===');
		System.debug(this.queueAccountList);
		System.debug('Next Page=' + this.nextPage);
		System.debug('===END_CUENTAS_EN_COLA===');
	}

	public void execute(QueueableContext context) {
		System.debug('Pagina=' + String.valueOf(this.nextPage - 1));
		if (!this.queueAccountList.isEmpty()) {
			Database.UpsertResult[] accountResults = Database.upsert(this.queueAccountList, Account.Fields.Cliente__c, false);
			Database.UpsertResult[] contactResults = Database.upsert(this.queueContactList, Contact.Fields.Id_Contacto__c, false);

			List<Integer> upAccountResults = ETC_Utility.showQueueResult(accountResults, 'Cuentas', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upAccountResults[0] + ' Registros exitosos. Cuentas');
			System.debug('Se procesaron: ' + upAccountResults[1] + ' Registros con errores. Cuentas');

			List<Integer> upContactResults = ETC_Utility.showQueueResult(contactResults, 'Contactos', this.nextPage - 1, false);
			System.debug('Se procesaron: ' + upContactResults[0] + ' Registros exitosos. Contactos');
			System.debug('Se procesaron: ' + upContactResults[1] + ' Registros con errores. Contactos');

			if (!this.isSinglePage) {
				ETC_GetAccountsQueue.queue(this.nextPage, false, this.usersByAgentCode);
			}
		}
	}

	@future(callout=true)
	public static void queue(Integer page, Boolean single, Map<String,String> users) {
		execute(page, single, users);
	}

	public static void execute(Integer page, Boolean single, Map<String,String> users) {
		ETC_GetAccountsQueue q = new ETC_GetAccountsQueue(page, single, users);
		System.enqueueJob(q);
	}
}