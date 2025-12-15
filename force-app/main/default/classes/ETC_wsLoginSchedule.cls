public with sharing class ETC_wsLoginSchedule implements Schedulable {
	public void execute(SchedulableContext sc) {
		ETC_wsLogin.refreshToken();
		Id jobId = sc.getTriggerId();
		System.abortJob(jobId);
		// ejecuta el nuevo proceso en el tiempo especificado
		if (!Test.isRunningTest()) {
			System.schedule(ETC_wsLoginSchedule.class.getName(), ETC_Utility.getCRONString(ETC_wsLogin.ENDPOINT_NAME), new ETC_wsLoginSchedule());
		}
	}

	public static void start() {
		if (!Test.isRunningTest()) {
			System.schedule(ETC_wsLoginSchedule.class.getName(), ETC_Utility.getCRONString(''), new ETC_wsLoginSchedule());
		}
	}
}
