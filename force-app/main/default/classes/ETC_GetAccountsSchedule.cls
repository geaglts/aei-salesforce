public with sharing class ETC_GetAccountsSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
		ETC_GetAccountsQueue.queue(1, false);
		Id jobId = sc.getTriggerId();
		System.abortJob(jobId);
		// ejecuta el nuevo proceso en el tiempo especificado
		if (!Test.isRunningTest()) {
			System.schedule(ETC_GetAccountsSchedule.class.getName(), ETC_Utility.getCRONString(ETC_GetAccountsWs.ENDPOINT_NAME), new ETC_GetAccountsSchedule());
		}
	}

	public static void start() {
		if (!Test.isRunningTest()) {
			System.schedule(ETC_GetAccountsSchedule.class.getName(), ETC_Utility.getCRONString(''), new ETC_GetAccountsSchedule());
		}
	}
}